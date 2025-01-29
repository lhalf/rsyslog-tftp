FROM debian:bookworm

RUN apt-get update -y
RUN apt-get install -y rsyslog

ENTRYPOINT ["/usr/sbin/rsyslogd", "-n"]
