#!/bin/sh

# Wrapper script to run the Efficiency report inside a Docker container
# Example:  ./efficiencyreport_run.sh daily UBooNe

# Valid VOS="NOvA SeaQuest MINERvA MINOS gm2 Mu2e UBooNe DarkSide DUNE CDMS MARS CDF"


export VERSIONRELEASE=0.11-2
export TOPDIR=$HOME/fife-reports-docker
export LOCALLOGDIR=${TOPDIR}/log
export SCRIPTLOGFILE=${LOCALLOGDIR}/minervareport_run.log
export CONFIGDIR=${TOPDIR}/config
export MYUID=`id -u`
export MYGID=`id -g`
ALARMFILENAME=${TOPDIR}/minervareport/docker-compose-alarm.yml

function usage {
    echo "Usage:    ./minerva_report.sh "
    echo ""
    exit
}

# Initialize everything
# Check arguments
case $1 in 
	-h)
		usage
		;;
	--help)
		usage
		;;
	-a)
		ALARMFLAG=1
		;;
	*)
		;;
esac

# Check to see if logdir exists.  Create it if it doesn't
if [ ! -d "$LOCALLOGDIR" ]; then
	mkdir -p $LOCALLOGDIR
fi

# Find docker-compose
PATH=$PATH:/usr/local/bin
DOCKER_COMPOSE_EXEC=`which docker-compose`

if [[ $? -ne 0 ]];
then
	ERRCODE=$?
	echo "Could not find docker-compose.  Exiting"
	exit $ERRCODE
fi


# Run the report container
echo "START" `date` >> $SCRIPTLOGFILE

if [[ $ALARMFLAG -eq 1 ]]; then
	${DOCKER_COMPOSE_EXEC} -f $ALARMFILENAME up -d 
else
	${DOCKER_COMPOSE_EXEC} up -d 
fi

# Error handling
if [ $? -ne 0 ]
then
	echo "Error sending minerva report. Please investigate" >> $SCRIPTLOGFILE
else
	echo "Sent report" >> $SCRIPTLOGFILE
fi
 
echo "END" `date` >> $SCRIPTLOGFILE
