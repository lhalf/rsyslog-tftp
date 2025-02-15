package main

import (
	"bufio"
	"flag"
	"io"
	"log"
	"os"
	"strings"

	"github.com/oakdoor/go-tftp/tftp"
)

type TFTPClient interface {
	Put(url string, r io.Reader, size int64) (err error)
}

func main() {
	log.SetFlags(log.Ldate | log.Ltime | log.Lmicroseconds)
	address, options := parseCmdLine()

	client, err := tftp.NewClient(options...)
	if err != nil {
		log.Fatalf("Failed to create TFTP client: %v", err)
	}

	reader := bufio.NewScanner(os.Stdin)

	processTransactions(reader, client, address)
}

func processTransactions(reader *bufio.Scanner, client TFTPClient, address string) {
	var inTransaction = false
	var messageBatch strings.Builder

	for reader.Scan() {
		switch reader.Text() {
		case "BEGIN TRANSACTION":
			inTransaction = true
		case "COMMIT TRANSACTION":
			if inTransaction {
				inTransaction = false
				if err := client.Put(address, strings.NewReader(messageBatch.String()), 0); err != nil {
					log.Printf("Error sending messages: %v", err)
				}
				messageBatch.Reset()
			}
		default:
			if inTransaction {
				messageBatch.WriteString(reader.Text() + "\n")
			}
		}
	}
}

func parseCmdLine() (string, []tftp.ClientOpt) {
	windowsize := flag.Int("windowsize", 64, "TFTP windowsize parameter.")
	blocksize := flag.Int("blocksize", 1408, "TFTP blocksize parameter.")
	retransmit := flag.Int("retransmit", 3, "TFTP retransmit parameter.")
	timeout := flag.Int("timeout", 1, "TFTP timeout parameter.")
	singleport := flag.Int("single-port", 0, "The client will use the specified value as the UDP src port for the TFTP transaction, making firewall configuration easier. If not specified or 0, standard TFTP ephemeral ports are used instead.")
	flag.Parse()

	if flag.NArg() != 1 {
		log.Println("USAGE: ")
		log.Println(os.Args[0], "[--windowsize [64]] [--blocksize [1408]] [--single-port [0]] [--retransmit [3]] [--timeout [1]] tftp://0.0.0.0/test_file")
		log.Println()
		os.Exit(1)
	}

	var address = flag.Args()[0]
	var options = []tftp.ClientOpt{tftp.ClientBlocksize(*blocksize), tftp.ClientWindowsize(*windowsize), tftp.ClientRetransmit(*retransmit), tftp.ClientTimeout(*timeout), tftp.ClientListenPort(*singleport)}
	return address, options
}
