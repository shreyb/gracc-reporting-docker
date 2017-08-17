#!/bin/sh

# Wrapper script to run the Efficiency report inside a Docker container
# Example:  ./efficiencyreport_run.sh daily UBooNe

# Valid VOS="NOvA SeaQuest MINERvA MINOS gm2 Mu2e UBooNe DarkSide DUNE CDMS MARS CDF"

export VERSIONRELEASE=0.11.4b
export TOPDIR=$HOME/fife-reports-docker
export LOCALLOGDIR=${TOPDIR}/log
export SCRIPTLOGFILE=${LOCALLOGDIR}/efficiencyreport_run.log
export REPORTLOGFILE=${LOCALLOGDIR}/efficiencyreport.log
export CONFIGDIR=${TOPDIR}/config
export UPDATEPROMDIR=${TOPDIR}/updateinfo

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

function dc_error_handle {
	SHELLERROR=$1
	DCERROR=$2
	ERRMSG=$3
	if [ $SHELLERROR -ne 0 ] || [ $DCERROR -ne 0 ];
	then
		ERRCODE=`expr $SHELLERROR + $DCERROR`
		echo $ERRMSG >> $SCRIPTLOGFILE 
		echo "END" `date` >> $SCRIPTLOGFILE
		exit $ERRCODE
	fi
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

${DOCKER_COMPOSE_EXEC} up 
ERR=$?
dc_EXITCODE=`${DOCKER_COMPOSE_EXEC} ps -q | xargs docker inspect -f '{{ .State.ExitCode}}'`
MSG="Error sending report for ${vo}. Please investigate"

dc_error_handle $ERR $dc_EXITCODE "$MSG"

echo "Sent report for $vo" >> $SCRIPTLOGFILE

# Update Prometheus metrics
${DOCKER_COMPOSE_EXEC} -f ${UPDATEPROMDIR}/docker-compose.yml up -d
ERR=$?
dc_EXITCODE=`${DOCKER_COMPOSE_EXEC} -f ${UPDATEPROMDIR}/docker-compose.yml ps -q | xargs docker inspect -f '{{ .State.ExitCode}}'`
MSG="Error updating Prometheus Metrics"

dc_error_handle $ERR $dc_EXITCODE "$MSG"

echo "Updated Prometheus Metrics" >> $SCRIPTLOGFILE
echo "END" `date` >> $SCRIPTLOGFILE

exit 0
