# FIFE base image for gracc-reporting
FROM shreyb/gracc-reporting:fife_0.9-2

# Executable
ENTRYPOINT ["sh", "-c", "efficiencyreport -E $VO -s \"$START\" -e \"$END\" -F GPGrid -c /home/ifmon/fife-config/fife.config -d"]
