set shell := ["bash", "-euc"]

[working-directory: 'go-tftp']
build:
    go build -o ../build/omtftp ../omtftp/omtftp.go
    go build -o ../build/imtftp ../imtftp/imtftp.go

[working-directory: 'tests']
test: build
    ./test.sh