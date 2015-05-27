#! /bin/sh

client=$1

if [ "$client" = "" ]; then
  echo "Usage: make.sh <hostname>"
  exit 1
fi

./clean.sh
./update.sh
./build.sh
#./buildroot

sed -i "s/raspberrypi/${client}/" ./bootfs/installer-config.txt
