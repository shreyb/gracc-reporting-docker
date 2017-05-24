# FIFE base image for gracc-reporting
FROM shreyb/gracc-reporting:fife_0.9-1

# Executable
ENTRYPOINT ["sh", "-c", "efficiencyreport -E $VO -s \"$START\" -e \"$END\" -F GPGrid"]
