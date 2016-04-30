#! /bin/bash

netinst="../raspbian-ua-netinst"
branch="../netinst.branch"
wpa="../wpa.conf"

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
