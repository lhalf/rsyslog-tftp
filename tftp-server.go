// Copyright (C) 2025 PA Knowledge Ltd.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

package main

import (
	"flag"
	"fmt"
	"io"
	"log"
	"os"

	"github.com/oakdoor/go-tftp/tftp"
)

func toStdOut(writeRequest tftp.WriteRequest) {
	_, err := io.Copy(os.Stdout, writeRequest)
	if err != nil {
		log.Println("Error writing to stdout:", err)
		writeRequest.WriteError(tftp.ErrCodeAccessViolation, "Error writing to stdout")
		return
	}
	return
}

func main() {
	var singlePortMode = flag.Bool("single-port", false, "When set the server will not use standard ephemeral ports for the TFTP transaction, making firewall configuration easier.")
	var port = flag.Int("port", 69, "The UDP port the server will listen on.")
	flag.Parse()

	opts := []tftp.ServerOpt{tftp.ServerSinglePort(*singlePortMode)}

	server, err := tftp.NewServer(fmt.Sprintf(":%d", *port), opts...)
	if err != nil {
		log.Fatal(err)
	}

	server.WriteHandler(tftp.WriteHandlerFunc(toStdOut))

	log.Fatal(server.ListenAndServe())
}
