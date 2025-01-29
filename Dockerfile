FROM docker.io/redhat/ubi9

ADD rsyslog-rhel.repo rsyslog-daily-rhel.repo /etc/yum.repos.d/

RUN yum install -y rsyslog

ENTRYPOINT ["/usr/sbin/rsyslogd", "-n"]
