FROM debian:bookworm

ENV RSYSLOG_DEBUGLOG="true"

RUN apt-get update -y
RUN apt-get install -y rsyslog

ENTRYPOINT ["/usr/sbin/rsyslogd", "-d", "-n"]
