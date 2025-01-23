FROM debian:bookworm

COPY opensuse-repo.list /etc/apt/sources.list.d/
COPY opensuse-repo.gpg /etc/apt/trusted.gpg.d/
RUN chmod a+r /etc/apt/trusted.gpg.d/opensuse-repo.gpg

RUN apt-get update -y
RUN apt-get install -y rsyslog rsyslog-omhttp rsyslog-mmjsonparse

EXPOSE 514

ENTRYPOINT ["/usr/sbin/rsyslogd", "-n"]
