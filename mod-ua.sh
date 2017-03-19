#! /bin/bash

WIFI=false
CLIENT="raspberrypi"
netinst="../raspbian-ua-netinst"
branch="../netinst.branch"
wpa="../wpa.conf"

GOPTS=$(getopt -n 'mod-ua.sh' -o n:w --long name:,wifi -- "$@")
if [ $? != 0 ] ; then echo "!!! Failed parsing options." >&2 ; exit 1 ; fi
eval set -- "$GOPTS"

while true; do
  case "$1" in
    -w | --wifi ) WIFI=true; shift ;;
    -n | --name ) CLIENT="$2"; shift; shift ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

# Check if the `raspbian-ua-netinst` directory is present.
if [ ! -d $netinst ]; then
  echo "!!! A clone of raspbian-ua-netinst could not be found." >&2
  exit 1
fi

# Check if `netinst.branch` file exists
# This file contains the name of the branch that should be used.
if [ ! -e $branch ]; then
  echo "!!! Could not find $branch" >&2
  echo "    This file should contain the name of the branch to be used."
  echo "    Both the branchname of raspbian-ua-netinst and the branchname of mod-raspbian-ua-netinst must be the same."
  exit 1
fi
branch=$(cat $branch)


echo ""
echo ""
echo ""
echo "Settings being used:"
echo "Wi-fi=$WIFI"
echo "Name=$CLIENT"
echo "Branch=$branch"
echo ""

echo ""
echo ""
echo ""
echo "**************************************************"
echo "*** Updating the RASPBERRYPI-UA-NETINST files ****"
echo "**************************************************"
echo ""
pushd $netinst/
  git pull
  git fetch origin
  git checkout "$branch"
  git reset --hard "origin/$branch" && \
  git clean -f -d
popd

echo ""
echo ""
echo ""
echo "**************************************************"
echo "*** Putting modifications in place ***************"
echo "**************************************************"
echo ""
cp -rv ./overlay/* $netinst/
mkdir -p $netinst/config/installer
if [ "$WIFI" == true ]; then
  echo "   ...adding wpa_supplicant.conf to installer!"
  echo "ifname=wlan0"           >> $netinst/installer-config.txt
  echo "drivers_to_load=8192cu" >> $netinst/installer-config.txt
  cp -rv $wpa $netinst/config/wpa_supplicant.conf
fi


echo ""
echo ""
echo ""
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "@@@ Building RASPBERRYPI-UA-NETINST image @@@@@@@@"
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo ""
pushd $netinst/
  # Check exitcode of prev command.
  rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
  # change the hostname in the default installer-config.txt
  sed -i "s/raspberrypi/${CLIENT}/" ./installer-config.txt
  echo ""
  echo ""
  echo ""
  echo "**************************************************"
  echo "*** Cleaning the installer ***********************"
  echo "**************************************************"
  echo ""
  ./clean.sh

  echo ""
  echo ""
  echo ""
  echo "**************************************************"
  echo "*** Updating the installer packages **************"
  echo "**************************************************"
  echo ""
  ./update.sh

  echo ""
  echo ""
  echo ""
  echo "**************************************************"
  echo "*** Building the installer ***********************"
  echo "**************************************************"
  echo ""
  # We don't need the zip file
  sed -i 's/cd bootfs && zip/#not zipping#/' ./build.sh
  sed -i '/#not zipping#/{n;s/.*/#############/}' ./build.sh
  ./build.sh
  # By default don't `./buildroot`
  #./buildroot.sh

  # At the end we don't `./clean.sh` so we can use the files in `./bootfs/` directly.
popd
