set -eu

pod=rsyslog
input_pod=input
output_pod=output

trap 'echo "stopping all pods..."; podman stop --all' EXIT

echo "building pod ${pod}..."
podman build --file Dockerfile --tag ${pod} . > /dev/null

echo "starting network..."
podman network create ${pod} > /dev/null 2>&1 || true

echo "starting ${input_pod}..."
podman run \
	--detach \
	--replace \
	-v "$(pwd)/input/rsyslog.conf:/etc/rsyslog.conf":Z \
	-v "$(pwd)/input/stdin-to-tftp.sh:/usr/bin/stdin-to-tftp.sh":Z \
	-v "$(pwd)/build/tftp-client:/usr/bin/tftp-client":Z \
	-p "10514:514" \
	--name ${input_pod} \
	--network ${pod} \
	${pod}

echo "starting ${output_pod}..."
podman run \
	--detach \
	--replace \
	-v "$(pwd)/output/rsyslog.conf:/etc/rsyslog.conf":Z \
	-v "$(pwd)/build/tftp-server:/usr/bin/tftp-server":Z \
	--name ${output_pod} \
	--network ${pod} \
	${pod}

echo "sending messages at ${input_pod}..."
echo "message 1" | nc -w1 127.0.0.1 10514
echo "message 2" | nc -w1 127.0.0.1 10514
echo "message 3" | nc -w1 127.0.0.1 10514
echo "message 4" | nc -w1 127.0.0.1 10514

echo "${input_pod} logs..."
podman logs input

echo "${output_pod} logs..."
podman logs output