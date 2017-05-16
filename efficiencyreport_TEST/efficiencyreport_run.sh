#!/bin/sh

# Wrapper script to run the Efficiency report inside a Docker container
# Example:  ./efficiencyreport_run.sh daily UBooNe

# Valid VOS="NOvA SeaQuest MINERvA MINOS gm2 Mu2e UBooNe DarkSide DUNE CDMS MARS CDF"


VERSIONRELEASE=0.6-2
TOPDIR=$HOME/fife-reports-docker
LOCALLOGDIR=$TOPDIR/log
SCRIPTLOGFILE=$LOCALLOGDIR/efficiencyreport_run.log     # Ideally should be in /var/log/gracc-reporting
MYUID=`id -u`
MYGID=`id -g`

function usage {
    echo "Usage:    ./efficiencyreport_run.sh <time period> <VO>"
    echo ""
    echo "Time periods are: daily, weekly, bimonthly, monthly, yearly"
    exit
}

function set_dates {
        case $1 in
                "daily") starttime=`date --date='1 day ago' +"%F %T"`;;
                "weekly") starttime=`date --date='1 week ago' +"%F %T"`;;
                "bimonthly") starttime=`date --date='2 month ago' +"%F %T"`;;
                "monthly") starttime=`date --date='1 month ago' +"%F %T"`;;
                "yearly") starttime=`date --date='1 year ago' +"%F %T"`;;
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

endtime=`date +"%F %T"`

vo=$2
set_dates $1

# Check to see if logdir exists.  Create it if it doesn't
if [ ! -d "$LOCALLOGDIR" ]; then
	mkdir -p $LOCALLOGDIR
fi

# Run the report container
echo "START" `date` >> $SCRIPTLOGFILE

docker run -e VO=$vo \
	-e START="$starttime" \
	-e END="$endtime" \
	-e MYGID=$MYGID \
	-e MYUID=$MYUID \
	-v $LOCALLOGDIR:/var/log \
	-d shreyb/gracc-reporting:efficiency-report_$VERSIONRELEASE

# Error handling
if [ $? -ne 0 ]
then
	echo "Error sending report for $vo . Please investigate" >> $SCRIPTLOGFILE
else
	echo "Sent report for $vo" >> $SCRIPTLOGFILE
fi
 
echo "END" `date` >> $SCRIPTLOGFILE
