# CentOS 7 base image
FROM shreyb/gracc-reporting:base-0.5-1

# Run this container as ifmon
USER ifmon 

# Executable
ENTRYPOINT ["sh", "-c", "efficiencyreport -E $VO -s \"$START\" -e \"$END\" -F GPGrid -d"]
