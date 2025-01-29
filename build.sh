mkdir -p build
pushd go-tftp > /dev/null
    echo building tftp-client...
    go build -o ../build/tftp-client cmd/tftp-client/main.go
    echo building tftp-server...
    go build -o ../build/tftp-server cmd/tftp-server/main.go
popd > /dev/null