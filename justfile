set shell := ["bash", "-euc"]

VERSION := `git describe --tags --abbrev=0 2>/dev/null || echo v0.0.0`

[working-directory: 'cmd/omtftp']
build ARCH="amd64":
    GOARCH={{ARCH}} go build -o ../../build/{{ARCH}}/imtftp ../imtftp/imtftp.go
    GOARCH={{ARCH}} go build -o ../../build/{{ARCH}}/omtftp omtftp.go

[working-directory: 'tests']
test: build
    ./test.sh

[working-directory: 'build']
package PACKAGER="deb" ARCH="amd64": (build ARCH)
    cd {{ARCH}} && ARCH={{ARCH}} VERSION={{VERSION}} \
        nfpm package --config ../../package/nfpm.yaml --packager {{PACKAGER}} --target ..

package-all: (package "deb") (package "deb" "arm64") (package "rpm") (package "rpm" "arm64")