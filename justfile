set shell := ["bash", "-euc"]

[working-directory: 'cmd/omtftp']
build ARCH="amd64":
    GOARCH={{ARCH}} go build -o ../../build/{{ARCH}}/imtftp ../imtftp/imtftp.go
    GOARCH={{ARCH}} go build -o ../../build/{{ARCH}}/omtftp omtftp.go

[working-directory: 'tests']
test: build
    ./test.sh

[working-directory: 'build']
package ARCH="amd64": (build ARCH)
    cd {{ARCH}} && ARCH={{ARCH}} VERSION="$(git describe --tags --abbrev=0 2>/dev/null || echo v0.0.0)" \
        nfpm package --config ../../package/nfpm.yaml --packager deb --target ..

package-all: package (package "arm64")