set -eu

pod=rsyslog
input_pod=input
output_pod=output

echo "building pod ${pod}..."
podman build --quiet --file Dockerfile --tag ${pod} . > /dev/null

echo "starting network..."
podman network create ${pod} > /dev/null || true

echo "starting ${input_pod}..."
podman run \
	--detach \
	--replace \
	-v "$(pwd)/input/rsyslog.conf:/etc/rsyslog.conf":Z \
	-p "10514:10514" \
	--name ${input_pod} \
	--network ${pod} \
	${pod}

echo "starting ${output_pod}..."
podman run \
	--detach \
	--replace \
	-v "$(pwd)/output/rsyslog.conf:/etc/rsyslog.conf":Z \
	-v "$(pwd)/outputs:/outputs" \
	--name ${output_pod} \
	--network ${pod} \
	${pod}
