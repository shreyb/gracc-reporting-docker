#gracc-reporting base image
FROM shreyb/gracc-reporting:base_0.11.4

# ifmon user setup 
RUN useradd ifmon 

# Run anything after this as ifmon 
USER ifmon

# Set up config dir for future bind-mounting
RUN cd /home/ifmon \
  && mkdir gracc-config \
  && mkdir -p log
