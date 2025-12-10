set shell := ["bash", "-euc"]

[working-directory: 'cmd/omtftp']
build:
    go build -o ../../build/imtftp ../imtftp/imtftp.go
    go build -o ../../build/omtftp omtftp.go

[working-directory: 'tests']
test: build
    ./test.sh