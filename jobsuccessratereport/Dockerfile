# CentOS 7 base image
FROM shreyb/gracc-reporting:base-0.5-1

# Run as ifmon
USER ifmon

# Run executable
ENTRYPOINT ["sh", "-c", "jobsuccessratereport -E $VO -s \"$START\" -e \"$END\" -d"]
