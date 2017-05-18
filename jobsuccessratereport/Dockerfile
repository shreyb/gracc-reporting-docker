# FIFE base image for gracc-reporting
FROM shreyb/gracc-reporting:fife_0.8-1

# Run executable
ENTRYPOINT ["sh", "-c", "jobsuccessratereport -E $VO -s \"$START\" -e \"$END\""]
