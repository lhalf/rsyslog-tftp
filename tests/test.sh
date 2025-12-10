set -eu

pod=rsyslog
input=omtftp
output=imtftp

function on_exit()
{
  echo "${input} logs..."
  podman logs ${input}

  echo "${output} logs..."
  podman logs ${output}

  echo "stopping all pods..."
  podman stop --all
}

trap on_exit EXIT

echo "building pod ${pod}..."
podman build --file Dockerfile --tag ${pod} . > /dev/null

echo "starting network..."
podman network create ${pod} > /dev/null 2>&1 || true

echo "starting ${input}..."
podman run \
  --privileged \
	--detach \
	--replace \
	-v "$(pwd)/${input}.conf:/etc/rsyslog.conf":Z \
	-v "$(pwd)/../build/omtftp:/usr/bin/omtftp":Z \
	-p "10514:514" \
	--name ${input} \
	--network ${pod} \
	${pod}

echo "starting ${output}..."
podman run \
  --privileged \
	--detach \
	--replace \
	-v "$(pwd)/${output}.conf:/etc/rsyslog.conf":Z \
	-v "$(pwd)/../build/imtftp:/usr/bin/imtftp":Z \
	-p "8069:69" \
	--name ${output} \
	--network ${pod} \
	${pod}

echo "sending messages at ${input}..."
echo "<1>Jan 22 12:34:56 myhostname myapp[1234]: First message." | nc -w1 127.0.0.1 10514
echo "<2>Jan 22 12:34:57 myhostname myapp[2345]: Second message." | nc -w1 127.0.0.1 10514
echo "<3>Jan 22 12:34:58 myhostname myapp[3456]: Third message." | nc -w1 127.0.0.1 10514
echo "<4>Jan 22 12:34:59 myhostname myapp[4567]: Fourth message." | nc -w1 127.0.0.1 10514

sleep 1
