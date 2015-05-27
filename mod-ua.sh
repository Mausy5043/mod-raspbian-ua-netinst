#! /bin/sh

client=$1
netinst="../raspbian-ua-netinst"

if [ "$client" = "" ]; then
  echo "Usage: make.sh <hostname>"
  exit 1
fi

echo "Put modifications in place"
cp installer-config.txt $netinst/
cp post-install.txt $netinst/
cp -r config $netinst/

echo "Building image"
pushd ../raspbian-ua-netinst

./clean.sh
./update.sh
./build.sh

sed -i "s/raspberrypi/${client}/" ./bootfs/installer-config.txt

#./buildroot

popd
