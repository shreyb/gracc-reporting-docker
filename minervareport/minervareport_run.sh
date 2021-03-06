#!/bin/sh

# Wrapper script to run the minerva report inside a Docker container


export VERSIONRELEASE=1.0
export TOPDIR=$HOME/fife-reports-docker
export LOCALLOGDIR=${TOPDIR}/log
export SCRIPTLOGFILE=${LOCALLOGDIR}/minervareport_run.log
export CONFIGDIR=${TOPDIR}/config
ALARMFILENAME=${TOPDIR}/minervareport/docker-compose-alarm.yml
export UPDATEPROMDIR=${TOPDIR}/updateinfo

function usage {
    echo "Usage:    ./minerva_report.sh [-a] [-p]"
    echo "-a is alarm flag (sends shorter report)"
    echo "-p flag (optional) logs report runs to prometheus pushgateway"
    echo ""
    exit
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

function prom_push {
        # Update Prometheus metrics
        export UPDATEPROMDIR=${TOPDIR}/updateinfo

        ${DOCKER_COMPOSE_EXEC} -f ${UPDATEPROMDIR}/docker-compose.yml up -d
        ERR=$?
        dc_EXITCODE=`${DOCKER_COMPOSE_EXEC} -f ${UPDATEPROMDIR}/docker-compose.yml ps -q | xargs docker inspect -f '{{ .State.ExitCode}}'`
        MSG="Error updating Prometheus Metrics"

        dc_error_handle $ERR $dc_EXITCODE "$MSG"

        echo "Updated Prometheus Metrics" >> $SCRIPTLOGFILE
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
		shift
		;;
	*)
		;;
esac

# Check for prometheus flag
if [[ $1 == "-p" ]] ;
then
        PUSHPROMMETRICS=1
        echo "Pushing metrics"
else
        PUSHPROMMETRICS=0
fi

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
	XARGS="-f $ALARMFILENAME"
else
	XARGS=""
fi

${DOCKER_COMPOSE_EXEC} $XARGS up -d 
ERR=$?
dc_EXITCODE=`${DOCKER_COMPOSE_EXEC} $XARGS ps -q | xargs docker inspect -f '{{ .State.ExitCode}}'`
MSG="Error sending minerva report. Please investigate"

dc_error_handle $ERR $dc_EXITCODE "$MSG"

echo "Sent report" >> $SCRIPTLOGFILE

if [[ $PUSHPROMMETRICS == 1 ]] ;
then
        prom_push
fi

echo "END" `date` >> $SCRIPTLOGFILE
exit 0
