#!/bin/bash -e

if `ls /packages/*.deb > /dev/null 2>&1`
then
	echo "Adding packages"
	ls -l /packages/*.deb
	
	cd /var/www/html
	reprepro includedeb all /packages/*.deb
else
	echo "No packages to add"
fi
