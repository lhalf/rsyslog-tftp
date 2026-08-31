FROM docker.io/redhat/ubi10

ARG PACKAGE

COPY ${PACKAGE} /tmp/rsyslog-tftp.rpm

RUN dnf install -y rsyslog /tmp/rsyslog-tftp.rpm \
    && dnf clean all \
    && rm /tmp/rsyslog-tftp.rpm

# the host apparmor profile attaches to /usr/sbin/rsyslogd and blocks signals to it
RUN cp /usr/sbin/rsyslogd /usr/local/bin/rsyslogd

ENTRYPOINT ["/usr/local/bin/rsyslogd", "-n"]
