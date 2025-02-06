dependencies=("go" "podman")

for dep in "${dependencies[@]}"; do
  if ! command -v "$dep" > /dev/null 2>&1; then
    echo "missing dependency: $dep"
    exit 1
  fi
done

rm -rf build
mkdir -p build

pushd go-tftp > /dev/null
    echo building omtftp...
    go build -o ../build/omtftp ../omtftp/omtftp.go
    echo building tftp-server...
    go build -o ../build/tftp-server ../imtftp/tftp-server.go
popd > /dev/null