FROM docker.io/redhat/ubi10

RUN dnf install -y rsyslog

ENTRYPOINT ["/usr/sbin/rsyslogd", "-n"]
