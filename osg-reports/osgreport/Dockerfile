# OSG base image for gracc-reporting
FROM shreyb/gracc-reporting:base_0.7-1

# Executable
ENTRYPOINT ["sh", "-c", "osgreport -s \"$starttime\" -e \"$endtime\" -r \"$reporttype\" -d"]
