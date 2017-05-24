# FIFE base image for gracc-reporting
FROM shreyb/gracc-reporting:fife_0.9-1

# Run executable
ENTRYPOINT ["sh", "-c", "jobsuccessratereport -E $VO -s \"$START\" -e \"$END\""]
