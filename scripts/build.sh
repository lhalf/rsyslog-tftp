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
    echo building imtftp...
    go build -o ../build/imtftp ../imtftp/imtftp.go
popd > /dev/null