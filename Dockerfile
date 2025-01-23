FROM debian:bookworm

RUN apt-get update -y
RUN apt-get install -y rsyslog
