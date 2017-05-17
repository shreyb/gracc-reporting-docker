# OSG base image for gracc-reporting
FROM shreyb/gracc-reporting:base_0.7-1

# Executable
ENTRYPOINT ["sh", "-c", "osgtopoppusagereport -s \"$starttime\" -e \"$endtime\" -N \"$number\" -d"]
