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
echo "<1>Jan 22 12:34:56 myhostname myapp[1234]: First message." | nc -w1 127.0.0.1 10514
echo "<2>Jan 22 12:34:57 myhostname myapp[1234]: Second message." | nc -w1 127.0.0.1 10514
echo "<3>Jan 22 12:34:58 myhostname myapp[1234]: Third message." | nc -w1 127.0.0.1 10514
echo "<4>Jan 22 12:34:59 myhostname myapp[1234]: Fourth message." | nc -w1 127.0.0.1 10514

echo "${input_pod} logs..."
podman logs input

echo "${output_pod} logs..."
podman logs output