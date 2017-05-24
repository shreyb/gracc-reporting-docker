#gracc-reporting base image
FROM shreyb/gracc-reporting:base_0.9-1 

# ifmon user setup 
ENV MYGID 1003
ENV MYUID 1003
RUN useradd ifmon \
  && groupmod -g $MYGID ifmon \
  && usermod -u $MYUID ifmon \
  && chown $MYUID:$MYGID /var/log

# Run anything after this as ifmon 
USER ifmon
