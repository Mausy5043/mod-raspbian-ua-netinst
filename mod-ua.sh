#! /bin/bash

client=$1
wifi=$2
netinst="../raspbian-ua-netinst"
branch="../netinst.branch"
wpa="../wpa.conf"

# Check for empty arg1
if [ "$client" = "" ]; then
  echo "Usage: mod-ua.sh <hostname> [-wifi]"
  exit 1
fi

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
echo "Updating the mod-ua files..."
echo "*********"
git pull
git fetch origin
git checkout "$branch"
git reset --hard "origin/$branch" && \
git clean -f -d

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
#cp -rv $netinst/scripts/etc/init.d/rcS $netinst/config/installer/rcS
if [[ $wifi -eq "-wifi" ]]; then
  echo "   adding wpa_supplicant.conf to installer"
  echo "ifname=wlan0" >> $netinst/config/installer-config.txt
  cp -rv $wpa $netinst/config/wpa_supplicant.conf
fi

echo ""
echo "*********"
echo "Building RASPBIAN-UA-NETINST image"
echo "*********"
pushd $netinst/
  # Check exitcode of prev command.
  rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

  sed -i "s/raspberrypi/${client}/" ./installer-config.txt
  ./clean.sh
  ./update.sh
  ./build.sh
  # By default don't `./buildroot`
  #./buildroot.sh

  # At the end we don't `./clean.sh` so we can use the files in `./bootfs/` directly.
popd
