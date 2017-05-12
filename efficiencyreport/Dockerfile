# CentOS 7 base image
FROM shreyb/gracc-reporting:base-0.5-1

ENTRYPOINT ["sh", "-c", "efficiencyreport -E $VO -s \"$START\" -e \"$END\" -F GPGrid -d"]
