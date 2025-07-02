# rsyslog-tftp

Uses [go-tftp](https://github.com/oakdoor/go-tftp) and the [omprog](https://www.rsyslog.com/doc/configuration/modules/omprog.html) and [improg](https://www.rsyslog.com/doc/configuration/modules/improg.html) modules to allow rsyslog to send messages via TFTP. The interface follows the standard for external output plugins, including support for batching, defined [here](https://github.com/rsyslog/rsyslog/blob/master/plugins/external/INTERFACE.md).

## Building

You will need [Go](https://go.dev/doc/install).

`./scripts/build.sh`

## Usage

See usage examples in [omtftp/rsyslog.conf](omtftp/rsyslog.conf) and [imtftp/rsyslog.conf](imtftp/rsyslog.conf).
