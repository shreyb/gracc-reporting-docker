#!/bin/bash

REPORTDIRS="efficiency jobsuccessrate minerva"
TOPDIR=/home/ifmon/fife-reports-docker

# git clone https://github.com/shreyb/GRACC-Reporting_Docker.git tmp
git clone ssh://p-fifemon@cdcvs.fnal.gov/cvs/projects/fifemon-email_reports-docker tmp

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

	# Cleanup

	# Grab latest image for this report
	IMGID=`docker images | grep -m 1 $DIR | awk '{print $3}'`

	# Clean up containers for that image
	for CONTAINERID in `docker ps -qa --filter ancestor=$IMGID`; 
	do
		docker rm $CONTAINERID ;
		echo "Removed container $CONTAINERID" ; 
	done

	# Clean up image
	docker rmi $IMGID

done

if [[ -d tmp ]]; 
then
	rm -Rf tmp
fi

exit 0
