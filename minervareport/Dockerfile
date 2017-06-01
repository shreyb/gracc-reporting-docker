# FIFE base image for gracc-reporting
FROM shreyb/gracc-reporting:fife_0.9-2

# Run executable - Note that we expect the config file to be at /home/ifmon/fife-config/minerva.config
ENTRYPOINT ["sh", "-c", "minervareport -c /home/ifmon/gracc-config/minerva.config -d"]
