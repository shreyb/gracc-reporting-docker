#!/bin/sh

# Wrapper script to run the Job Success Rate report for all VOs
# Example:  ./jobsuccessratereport_run.sh


VERSIONRELEASE=0.6-1
TOPDIR=$HOME/fife-reports-docker
LOCALLOGDIR=$TOPDIR/log
SCRIPTLOGFILE=$LOCALLOGDIR/jobsuccessratereport_run.log     # Ideally should be in /var/log/gracc-reporting
MYUID=`id -u`
MYGID=`id -g`

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

VOS="UBooNE NOvA DUNE Mu2e SeaQuest DarkSide"
YESTERDAY=`date --date yesterday +"%F %T"`
TODAY=`date +"%F %T"`

# Check to see if logdir exists.  Create it if it doesn't
if [ ! -d "$LOCALLOGDIR" ]; then
        mkdir -p $LOCALLOGDIR
fi

# Run the report in a docker container
echo "START" `date` >> $SCRIPTLOGFILE

for vo in ${VOS}
do
	echo $vo
	docker run -e VO=$vo \
        	-e START="$YESTERDAY" \
        	-e END="$TODAY" \
		-e MYGID=$MYGID \
		-e MYUID=$MYUID \
		-v $LOCALLOGDIR:/var/log \
		-d shreyb/gracc-reporting:job-success-rate-report_$VERSIONRELEASE

    # Error handling
	if [ $? -ne 0 ]
	then 
		echo "Error running report for $vo.  Please try running the report manually" >> $SCRIPTLOGFILE
	else
		echo "Sent report for $vo" >> $SCRIPTLOGFILE

	fi
done
 
echo "END" `date` >> $SCRIPTLOGFILE

