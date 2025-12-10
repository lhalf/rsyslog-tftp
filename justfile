set shell := ["bash", "-euc"]

[working-directory: 'cmd/omtftp']
build ARCH="amd64":
    GOARCH={{ARCH}} go build -o ../../build/{{ARCH}}/imtftp ../imtftp/imtftp.go
    GOARCH={{ARCH}} go build -o ../../build/{{ARCH}}/omtftp omtftp.go

[working-directory: 'tests']
test: build
    ./test.sh

package ARCH="amd64": (build ARCH)
    tar -czf build/{{ARCH}}.tar.gz --directory build/{{ARCH}} .

package-all: package (package "arm64")