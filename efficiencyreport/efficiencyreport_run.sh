#!/bin/sh

# Wrapper script to run the Efficiency report inside a Docker container
# Example:  ./efficiencyreport_run.sh daily UBooNe

# Valid VOS="NOvA SeaQuest MINERvA MINOS gm2 Mu2e UBooNe DarkSide DUNE CDMS MARS CDF"


export VERSIONRELEASE=0.11-2
export TOPDIR=$HOME/fife-reports-docker
export LOCALLOGDIR=${TOPDIR}/log
export SCRIPTLOGFILE=${LOCALLOGDIR}/efficiencyreport_run.log
export CONFIGDIR=${TOPDIR}/config
export MYUID=`id -u`
export MYGID=`id -g`

function usage {
    echo "Usage:    ./efficiencyreport_run.sh <time period> <VO>"
    echo ""
    echo "Time periods are: daily, weekly, bimonthly, monthly, yearly"
    exit
}

function set_dates {
        case $1 in
                "daily") export starttime=`date --date='1 day ago' +"%F %T"`;;
                "weekly") export starttime=`date --date='1 week ago' +"%F %T"`;;
                "bimonthly") export starttime=`date --date='2 month ago' +"%F %T"`;;
                "monthly") export starttime=`date --date='1 month ago' +"%F %T"`;;
                "yearly") export starttime=`date --date='1 year ago' +"%F %T"`;;
                *) echo "Error: unknown period $1. Use weekly, monthly or yearly"
                         exit 1;;
        esac
        echo $starttime
}

# Initialize everything
# Check arguments
if [[ $# -ne 2 ]] || [[ $1 == "-h" ]] || [[ $1 == "--help" ]] ;
then
    usage
fi

export endtime=`date +"%F %T"`

export vo=$2
set_dates $1

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

${DOCKER_COMPOSE_EXEC} up -d 

# Error handling
if [ $? -ne 0 ]
then
	echo "Error sending report for $vo . Please investigate" >> $SCRIPTLOGFILE
else
	echo "Sent report for $vo" >> $SCRIPTLOGFILE
fi
 
echo "END" `date` >> $SCRIPTLOGFILE
