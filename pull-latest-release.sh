#!/bin/bash

REPORTDIRS="efficiency jobsuccessrate"
TOPDIR=/home/ifmon/fife-reports-docker

git clone https://github.com/shreyb/GRACC-Reporting_Docker.git tmp

if [[ $? -ne 0 ]]; 
then
	echo "Could not clone git repo"
	exit 1
fi

for DIR in ${REPORTDIRS};
do
	DIRNAME=${DIR}report 
	echo $DIRNAME 
	if [[ -d "tmp/${DIRNAME}" ]];
	then
		DESTDIR=${TOPDIR}/${DIRNAME}

		if [[ -d "$DESTDIR" ]];
		then
			rm -Rf $DESTDIR
		fi
		
		mkdir -p $DESTDIR
		FILES="tmp/${DIRNAME}/${DIRNAME}_run.sh tmp/${DIRNAME}/docker-compose.yml"
		
		for FILE in ${FILES};
		do
			if [[ -f "$FILE" ]];
			then
				cp $FILE $DESTDIR
			fi
		done
	fi
done

if [[ -d tmp ]]; 
then
	rm -Rf tmp
fi

exit 0
