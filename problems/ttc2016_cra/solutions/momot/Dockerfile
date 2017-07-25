FROM centos:centos7
MAINTAINER The MOMOT Project <alexandru.burdusel@kcl.ac.uk>

RUN yum update -y && \
yum install -y wget && \
yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel && \
yum clean all

# Add app

ADD app/ /opt/app

# Run app
ENTRYPOINT ["java", "jar", "/opt/mdeo.jar"]

# Publish result

