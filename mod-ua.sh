#! /bin/bash

GOPTS=`getopt -n 'mod-ua.sh' -o n:w --long name:,wifi -- "$@"`

if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

eval set -- "$GOPTS"

WIFI=false
CLIENT="raspberrypi"

while true; do
  case "$1" in
    -w | --wifi ) WIFI=true; shift ;;
    -n | --name ) CLIENT="$2"; shift; shift ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

echo
echo WIFI="$WIFI"
echo NAME="$CLIENT"
echo

netinst="../raspbian-ua-netinst"
branch="../netinst.branch"
wpa="../wpa.conf"

# Check if the `raspbian-ua-netinst` directory is present.
if [ ! -d $netinst ]; then
  echo "A clone of raspbian-ua-netinst could not be found."
  exit 1
fi

# Check if `netinst.branch` file exists
# This file contains the name of the branch that should be used.
if [ ! -e $branch ]; then
  echo "Could not find "$branch
  echo "This file should contain the name of the branch to be used."
  echo "Both the branchname of raspbian-ua-netinst and the branchname of mod-raspbian-ua-netinst must be the same."
  exit 1
fi
branch=$(cat $branch)

echo ""
echo "*********"
echo "Updating the raspbian-ua-netinst files..."
echo "*********"
pushd $netinst/
  # Check exitcode of prev command.
  rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

  git pull
  git fetch origin
  git checkout "$branch"
  git reset --hard "origin/$branch" && \
  git clean -f -d
popd

echo ""
echo "*********"
echo "Putting modifications in place"
echo "*********"
cp -rv ./overlay/* $netinst/
mkdir -p $netinst/config/installer

if [ "$WIFI" == true ]; then
  echo "   ...adding wpa_supplicant.conf to installer!"
  echo "ifname=wlan0"           >> $netinst/installer-config.txt
  echo "drivers_to_load=8192cu" >> $netinst/installer-config.txt
  cp -rv $wpa $netinst/config/wpa_supplicant.conf
fi

echo ""
echo "*********"
echo "Building RASPBIAN-UA-NETINST image"
echo "*********"
pushd $netinst/
  # Check exitcode of prev command.
  rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

  sed -i "s/raspberrypi/${CLIENT}/" ./installer-config.txt

  echo
  echo "*** Cleaning the installer ***"
  ./clean.sh

  echo
  echo "*** Updating the packages for the installer ***"
  ./update.sh

  echo
  echo "*** Building the installer ***"
  # We don't need the zip file so throw away that line and the next
  sed -i 's/cd bootfs && zip/#not zipping#/' ./build.sh
  sed -i '/#not zipping#/{n;s/.*/#############/}' ./build.sh
  ./build.sh
  # By default don't `./buildroot`
  #./buildroot.sh

  # At the end we don't `./clean.sh` so we can use the files in `./bootfs/` directly.
popd
