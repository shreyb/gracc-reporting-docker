# gracc-reporting base image
FROM shreyb/gracc-reporting:base_0.11.4

# User gracc
RUN useradd gracc
USER gracc

# Set up config dir for future bind-mounting
RUN cd /home/gracc \
  && mkdir gracc-config \
  && mkdir log
