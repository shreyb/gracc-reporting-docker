#gracc-reporting base image
FROM shreyb/gracc-reporting:base_0.11.4

# ifmon user setup 
RUN useradd ifmon 
#  && chown `id -u ifmon`:`id -g ifmon` /var/log \
#  && chmod g+s /var/log \
#  && setfacl -d -R -m o::rw /var/log

# Run anything after this as ifmon 
USER ifmon

# Set up config dir for future bind-mounting
RUN cd /home/ifmon \
  && mkdir gracc-config \
  && mkdir -p log
