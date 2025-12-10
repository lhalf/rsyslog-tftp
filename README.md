# rsyslog-tftp

[![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/lhalf/rsyslog-tftp/on_commit.yml)](https://github.com/lhalf/rsyslog-tftp/actions/workflows/on_commit.yml)
[![MIT](https://img.shields.io/badge/license-MIT-blue)](./LICENSE)

TFTP module for [rsyslog](https://www.rsyslog.com/).

## Overview

Uses [go-tftp](https://github.com/oakdoor/go-tftp) and the [omprog](https://www.rsyslog.com/doc/configuration/modules/omprog.html) and [improg](https://www.rsyslog.com/doc/configuration/modules/improg.html) modules to allow rsyslog to send messages via TFTP. 
The interface follows the standard for external output plugins, including support for batching, defined [here](https://github.com/rsyslog/rsyslog/blob/master/plugins/external/INTERFACE.md).

## Usage

### omtftp

```
Usage of omtftp:
  -blocksize int
        TFTP blocksize parameter. (default 1408)
  -retransmit int
        TFTP retransmit parameter. (default 3)
  -single-port int
        The client will use the specified value as the UDP src port for the TFTP transaction, making firewall configuration easier. If not specified or 0, standard TFTP ephemeral ports are used instead.
  -timeout int
        TFTP timeout parameter. (default 1)
  -windowsize int
        TFTP windowsize parameter. (default 64)
```

```
module(load="omprog")
action(type="omprog"
       useTransactions="on"
       binary="/usr/bin/omtftp tftp://<URL>:69/")
```

### imtftp

```
Usage of imtftp:
  -port int
        The UDP port the server will listen on. (default 69)
  -single-port
        When set the server will not use standard ephemeral ports for the TFTP transaction, making firewall configuration easier.
```

```
module(load="improg")
input(type="improg"
      binary="/usr/bin/imtftp")
```
