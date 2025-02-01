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
    echo building tftp-client...
    go build -o ../build/tftp-client cmd/tftp-client/main.go
    echo building tftp-server...
    go build -o ../build/tftp-server ../output/tftp-server.go
popd > /dev/null