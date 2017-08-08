#gracc-reporting base image
FROM shreyb/gracc-reporting:base_0.11.4

# ifmon user setup 
#ENV MYGID 1003
#ENV MYUID 1003
#RUN useradd ifmon \
#  && groupmod -g $MYGID ifmon \
#  && usermod -u $MYUID ifmon \
#  && chown $MYUID:$MYGID /var/log
#
# instead of changing the GID and UID, let's instead just use the user ifmon and change /var/log to be writable by all.  
# No big security problem here

RUN useradd ifmon \
  && chown `id -u ifmon`:`id -g ifmon` /var/log \
  && chmod g+s /var/log \
  && setfacl -d -R -m o::rw /var/log

# Run anything after this as ifmon 
USER ifmon

# Set up config dir for future bind-mounting
RUN cd /home/ifmon \
  && mkdir gracc-config
