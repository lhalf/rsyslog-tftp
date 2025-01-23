set -eu

pod=rsyslog
input_pod=input
output_pod=output

echo "building pod ${pod}..."
podman build --quiet --file Dockerfile --tag ${pod} . > /dev/null

echo "starting ${input_pod}..."
podman run \
	--detach \
	--replace \
	-v "$(pwd)/input/rsyslog.conf:/etc/rsyslog.conf":Z \
	-p "10514:514" \
	--name ${input_pod} \
	${pod} \
	/usr/sbin/rsyslogd -n

echo "starting ${output_pod}..."
podman run \
	--detach \
	--replace \
	-v "$(pwd)/output/rsyslog.conf:/etc/rsyslog.conf":Z \
	--name ${output_pod} \
	${pod} \
	/usr/sbin/rsyslogd -n
