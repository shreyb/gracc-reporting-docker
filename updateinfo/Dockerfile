# CENTOS 7 image
FROM centos:7

# Set up libraries
# Get PIP.  We need it for now to grab PyPI's urllib3, since SL7 and CentOS' python-urllib3 is broken for SSL
RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum -y install python-pip && pip install -U pip 
RUN pip install prometheus_client && pip install requests
RUN touch /tmp/statefile.txt

# Copy in python executable
COPY update_info.py /tmp/update_info.py

CMD ["python", "/tmp/update_info.py"]

