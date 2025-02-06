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

func main() {
	log.SetFlags(log.Ldate | log.Ltime | log.Lmicroseconds)
	address, options := parseCmdLine()

	client, err := tftp.NewClient(options...)
	if err != nil {
		log.Fatalf("Failed to create TFTP client: %v", err)
	}

	reader := bufio.NewReader(os.Stdin)

	processTransactions(reader, client, address)
}

func processTransactions(reader *bufio.Reader, client *tftp.Client, address string) {
	for {
		line, err := reader.ReadString('\n')
		if err != nil {
			if err == io.EOF {
				log.Println("EOF received, exiting.")
				return
			}
			log.Printf("Error reading from stdin: %v", err)
			continue
		}

		if line != "BEGIN TRANSACTION" {
			continue
		}

		var messageBatch strings.Builder

		for {
			message, err := reader.ReadString('\n')
			if err != nil {
				log.Printf("Error reading message line: %v", err)
				break
			}

			if message == "COMMIT TRANSACTION" {
				if err := client.Put(address, strings.NewReader(messageBatch.String()), 0); err != nil {
					log.Printf("Error sending messages: %v", err)
				}
				break
			}

			messageBatch.WriteString(message + "\n")
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
