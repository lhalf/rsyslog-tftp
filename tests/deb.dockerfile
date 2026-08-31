FROM debian:trixie

ARG PACKAGE

RUN apt-get update && apt-get install -y --no-install-recommends rsyslog \
    && rm -rf /var/lib/apt/lists/*

COPY ${PACKAGE} /tmp/rsyslog-tftp.deb

RUN dpkg --install /tmp/rsyslog-tftp.deb && rm /tmp/rsyslog-tftp.deb

# the host apparmor profile attaches to /usr/sbin/rsyslogd and blocks signals to it
RUN cp /usr/sbin/rsyslogd /usr/local/bin/rsyslogd

ENTRYPOINT ["/usr/local/bin/rsyslogd", "-n"]
