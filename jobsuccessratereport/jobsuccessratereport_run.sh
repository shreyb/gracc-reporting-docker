#!/bin/sh

# Wrapper script to run the Job Success Rate report for all VOs
# Example:  ./jobsuccessratereport_run.sh

export VERSIONRELEASE=0.11.4b
export TOPDIR=$HOME/fife-reports-docker
export LOCALLOGDIR=$TOPDIR/log
export SCRIPTLOGFILE=$LOCALLOGDIR/jobsuccessratereport_run.log    
export REPORTLOGFILE=$LOCALLOGDIR/jobsuccessratereport.log     
export CONFIGDIR=${TOPDIR}/config
export UPDATEPROMDIR=${TOPDIR}/updateinfo

function usage {
    echo "Usage:    ./jobsuccessratereport_run.sh "
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

# Initialize everything
# Check arguments
if [[ $# -ne 0 ]] || [[ $1 == "-h" ]] || [[ $1 == "--help" ]] ;
then
    usage
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
	ERRCODE=`expr $ERR + $dc_EXITCODE`

	if [[ $ERRCODE -ne 0 ]];
	then
		echo $MSG >> $SCRIPTLOGFILE
	else
		echo "Sent report for $vo" >> $SCRIPTLOGFILE
	fi

	# Update Prometheus metrics
	${DOCKER_COMPOSE_EXEC} -f ${UPDATEPROMDIR}/docker-compose.yml up -d
	ERR=$?
	dc_EXITCODE=`${DOCKER_COMPOSE_EXEC} -f ${UPDATEPROMDIR}/docker-compose.yml ps -q | xargs docker inspect -f '{{ .State.ExitCode}}'`
	MSG="Error updating Prometheus Metrics.  Please check the docker logs"
	ERRCODE=`expr $ERR + $dc_EXITCODE`

	if [[ $ERRCODE -ne 0 ]];
	then
		echo $MSG >> $SCRIPTLOGFILE
	else
		echo "Updated Prometheus Metrics" >> $SCRIPTLOGFILE
	fi

done
 
echo "END" `date` >> $SCRIPTLOGFILE

exit 0
