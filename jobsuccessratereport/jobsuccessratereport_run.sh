#!/bin/sh

# Wrapper script to run the Job Success Rate report for all VOs
# Example:  ./jobsuccessratereport_run.sh

export VERSIONRELEASE=0.11.4b
export TOPDIR=$HOME/fife-reports-docker
export LOCALLOGDIR=$TOPDIR/log
export SCRIPTLOGFILE=$LOCALLOGDIR/jobsuccessratereport_run.log    
export REPORTLOGFILE=$LOCALLOGDIR/jobsuccessratereport.log     
export CONFIGDIR=${TOPDIR}/config

function usage {
    echo "Usage:    ./jobsuccessratereport_run.sh "
    echo ""
    exit
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

# Run the report in a docker container
echo "START" `date` >> $SCRIPTLOGFILE

for vo in ${VOS}
do
	echo $vo
	export vo
	${DOCKER_COMPOSE_EXEC} up

    # Error handling
	if [ $? -ne 0 ]
	then 
		echo "Error running report for $vo.  Please try running the report manually" >> $SCRIPTLOGFILE
	else
		echo "Sent report for $vo" >> $SCRIPTLOGFILE

	fi
done
 
echo "END" `date` >> $SCRIPTLOGFILE

