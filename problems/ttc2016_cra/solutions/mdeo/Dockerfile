FROM centos:centos7
MAINTAINER The MDEO Project <alexandru.burdusel@kcl.ac.uk>

RUN yum -y update; yum clean all
RUN yum -y install

RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''

RUN chmod 755 /start.sh
# EXPOSE 22
RUN ./start.sh
ENTRYPOINT ["/usr/sbin/sshd", "-D"]