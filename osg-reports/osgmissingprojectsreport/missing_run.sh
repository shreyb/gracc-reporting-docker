#!/bin/sh

# Wrapper script to run the OSG Flocking report inside a Docker container
# Example:  ./missing_run.sh weekly


export VERSIONRELEASE=0.11.4b
export TOPDIR=$HOME/gracc-reporting
export LOCALLOGDIR=${TOPDIR}/log
export SCRIPTLOGFILE=${LOCALLOGDIR}/missing_run.log
export REPORTLOGFILE=${LOCALLOGDIR}/missingproject.log
export CONFIGDIR=${TOPDIR}/config

function usage {
    echo "Usage:    ./missing_run.sh <time period>"
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
if [[ $# -ne 1 ]] || [[ $1 == "-h" ]] || [[ $1 == "--help" ]] ;
then
    usage
fi

set_dates $1
export endtime=`date +"%F %T"`
export REPORT_TYPES="XD OSG OSG-Connect"

# Check to see if logdir exists.  Create it if it doesn't
if [ ! -d "$LOCALLOGDIR" ]; then
        mkdir -p $LOCALLOGDIR
fi

touch ${REPORTLOGFILE}
chmod a+w ${REPORTLOGFILE}

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

for TYPE in ${REPORT_TYPES}
do
    echo $TYPE
    export $TYPE

    ${DOCKER_COMPOSE_EXEC} up -d
    ERR=$?
    dc_EXITCODE=`${DOCKER_COMPOSE_EXEC} ps -q | xargs docker inspect -f '{{ .State.ExitCode}}'`
    MSG="Error sending report. Please investigate"
    ERRCODE=`expr $ERR + $dc_EXITCODE`

    # Error handling
    if [ $ERRCODE -ne 0 ] 
    then
        echo "Error sending $TYPE report. Please investigate" >> $SCRIPTLOGFILE
    else
        echo "Sent $TYPE report" >> $SCRIPTLOGFILE
    fi  
done

echo "END" `date` >> $SCRIPTLOGFILE
exit 0
