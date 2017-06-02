#!/bin/bash

REPORTDIRS="efficiency jobsuccessrate minerva"
TOPDIR=/home/ifmon/fife-reports-docker

git clone https://github.com/shreyb/GRACC-Reporting_Docker.git tmp

if [[ $? -ne 0 ]]; 
then
	echo "Could not clone git repo"
	exit 1
fi

for DIR in ${REPORTDIRS};
do
	# Copy Report dirs
	DIRNAME=${DIR}report 
	echo $DIRNAME 
	if [[ -d "tmp/${DIRNAME}" ]];
	then
		DESTDIR=${TOPDIR}/${DIRNAME}

		if [[ -d "$DESTDIR" ]];
		then
			rm -Rf $DESTDIR
		fi
		
		cp -r tmp/${DIRNAME} ${DESTDIR}
	fi

	# Develop this a bit later
#	# Clean up containers
#	for CONTAINER in `docker ps -a | grep $DIR | awk '{print $1}'`; 
#	do 
#		docker rm $CONTAINER ; 
#		echo "Removed container $CONTAINER" ; 
#	done
#
#	# Clean up images - only remove the latest image!
#	docker rmi `docker images | grep -m 1 $DIR | awk '{print $3}'`

done

if [[ -d tmp ]]; 
then
	rm -Rf tmp
fi

exit 0
