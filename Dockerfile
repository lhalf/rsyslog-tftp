FROM debian:bookworm

RUN apt-get update -y
RUN apt-get install -y rsyslog

EXPOSE 514

ENTRYPOINT ["/usr/sbin/rsyslogd", "-n"]
