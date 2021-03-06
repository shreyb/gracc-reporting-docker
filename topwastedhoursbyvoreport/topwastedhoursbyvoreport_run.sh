#!/bin/sh

# Wrapper script to run the Job Success Rate report for all VOs
# Example:  ./topwastedhoursbyvo_run.sh

export VERSIONRELEASE=1.0
export TOPDIR=$HOME/fife-reports-docker
export LOCALLOGDIR=$TOPDIR/log
export SCRIPTLOGFILE=$LOCALLOGDIR/topwastedhoursbyvo_run.log    
export REPORTLOGFILE=$LOCALLOGDIR/topwastedhoursbyvo.log     
export CONFIGDIR=${TOPDIR}/config

function usage {
    echo "Usage:   ./topwastedhoursbyvo_run.sh [-p]"
    echo "-p flag (optional) logs report runs to prometheus pushgateway"
    echo ""
    exit
}

function dc_error_handle {
        SHELLERROR=$1
        DCERROR=$2
        ERRMSG=$3
	SMSG=$4
        if [ $SHELLERROR -ne 0 ] || [ $DCERROR -ne 0 ];
        then
                ERRCODE=`expr $SHELLERROR + $DCERROR`
                echo $ERRMSG >> $SCRIPTLOGFILE 
	else
		echo $SMSG >> $SCRIPTLOGFILE
        fi  
}

function prom_push {
        # Update Prometheus metrics
        export UPDATEPROMDIR=${TOPDIR}/updateinfo

        ${DOCKER_COMPOSE_EXEC} -f ${UPDATEPROMDIR}/docker-compose.yml up 
        ERR=$?
        dc_EXITCODE=`${DOCKER_COMPOSE_EXEC} -f ${UPDATEPROMDIR}/docker-compose.yml ps -q | xargs docker inspect -f '{{ .State.ExitCode}}'`
        MSG="Error updating Prometheus Metrics"
	SMSG="Updated Prometheus Metrics"

        dc_error_handle $ERR $dc_EXITCODE "$MSG" "$SMSG"
}

# Initialize everything
# Check arguments
if [[ $# -gt 1 ]] || [[ $1 == "-h" ]] || [[ $1 == "--help" ]] ;
then
    usage
fi

# Check for prometheus flag
if [[ $1 == "-p" ]] ;
then
        PUSHPROMMETRICS=1
        echo "Pushing metrics"
        shift 
else
        PUSHPROMMETRICS=0
fi

# Set script variables

VOS="UBooNE NOvA DUNE Mu2e SeaQuest DarkSide gm2"
export YESTERDAY=`date --date yesterday +"%F %T"`
export TODAY=`date +"%F %T"`

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

echo "START" `date` >> $SCRIPTLOGFILE

for vo in ${VOS}
do
	# Run the report in a docker container
	echo $vo
	export vo
	${DOCKER_COMPOSE_EXEC} up
	ERR=$?
	dc_EXITCODE=`${DOCKER_COMPOSE_EXEC} ps -q | xargs docker inspect -f '{{ .State.ExitCode}}'`
	MSG="Error sending report for ${vo}. Please investigate"
	SMSG="Sent report for $vo"
	
	dc_error_handle $ERR $dc_EXITCODE "$MSG" "$SMSG"

	if [[ $PUSHPROMMETRICS == 1 ]] ;
	then
		prom_push
	fi
done
 
echo "END" `date` >> $SCRIPTLOGFILE

exit 0
