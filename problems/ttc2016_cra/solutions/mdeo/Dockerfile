FROM centos:centos7
MAINTAINER The MDEO Project <alexandru.burdusel@kcl.ac.uk>

RUN yum update -y && \
yum install -y wget && \
yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel && \
yum clean all

# Run app
#ENTRYPOINT ["sh", "-c", "cd /var/app/current && java -jar mdeo.jar 1 10"]