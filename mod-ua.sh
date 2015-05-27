#! /bin/bash

client=$1
netinst="../raspbian-ua-netinst"
branch=$(cat ../netinst.branch)

if [ "$client" = "" ]; then
  echo "Usage: mod-ua.sh <hostname>"
  exit 1
fi

echo "Update the mod-ua files..."
git pull
git fetch origin
git checkout $branch
git reset --hard origin/$branch && \
git clean -f -d

echo "Update the raspbian-ua-netinst files..."
pushd ../raspbian-ua-netinst/
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

git pull
git fetch origin
git checkout $branch
git reset --hard origin/$branch && \
git clean -f -d
popd

echo "Put modifications in place"
cp installer-config.txt $netinst/
cp post-install.txt $netinst/
cp -r config $netinst/

echo "Building image"
pushd ../raspbian-ua-netinst/
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

./clean.sh
./update.sh
./build.sh

sed -i "s/raspberrypi/${client}/" ./bootfs/installer-config.txt

#./buildroot

popd
