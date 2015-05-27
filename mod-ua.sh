#! /bin/bash

client=$1
netinst="../raspbian-ua-netinst"
branch="../netinst.branch"

if [ ! -d $netinst ]; then
  echo "A clone of raspbian-ua-netinst could not be found."
  exit 1
fi
if [ ! -d $branch ]; then
  echo "Could not find "$branch
  echo "This file should contain the name of the branch to be used."
  echo "Both the raspbian-ua-netinst branch and the mod-raspbian-ua-netinst branch must have the same name."
  exit 1
fi
branch=$(cat $branch)



if [ "$client" = "" ]; then
  echo "Usage: mod-ua.sh <hostname>"
  exit 1
fi

echo ""
echo "*********"
echo "Update the mod-ua files..."
echo "*********"
git pull
git fetch origin
git checkout $branch
git reset --hard origin/$branch && \
git clean -f -d

echo ""
echo "*********"
echo "Update the raspbian-ua-netinst files..."
echo "*********"
pushd ../raspbian-ua-netinst/
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

git pull
git fetch origin
git checkout $branch
git reset --hard origin/$branch && \
git clean -f -d
popd

echo ""
echo "*********"
echo "Put modifications in place"
echo "*********"
echo -n "installer-config.txt - "
cp installer-config.txt $netinst/
echo -n "post-install.txt - "
cp post-install.txt $netinst/
echo -n "config/ - "
cp -r config $netinst/
echo "...ready."

echo ""
echo "*********"
echo "Building image"
echo "*********"
pushd ../raspbian-ua-netinst/
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

./clean.sh
./update.sh
./build.sh

sed -i "s/raspberrypi/${client}/" ./bootfs/installer-config.txt

#./buildroot

popd
