package main

import (
	"bufio"
	"io"
	"strings"
	"testing"
)

type MockTFTPClient struct {
	PutCallCount int
	PutURL       string
	PutError     error
	SentBatches  []string
}

func (m *MockTFTPClient) Put(url string, reader io.Reader, size int64) (err error) {
	m.PutCallCount++
	m.PutURL = url

	if reader != nil {
		data, err := io.ReadAll(reader)
		if err != nil {
			return err
		}
		m.SentBatches = append(m.SentBatches, string(data))
	}
	return m.PutError
}

func TestProcessTransactions_InvalidBeginIsIgnored(t *testing.T) {
	input := `WRONG TRANSACTION
Message 1
COMMIT TRANSACTION
`
	reader := bufio.NewScanner(strings.NewReader(input))
	mockClient := &MockTFTPClient{}
	address := "test_address"

	processTransactions(reader, mockClient, address)

	if mockClient.PutCallCount != 0 {
		t.Errorf("Expected Put to not be called")
	}
}

func TestProcessTransactions_BeginInsideTransactionIgnored(t *testing.T) {
	input := `BEGIN TRANSACTION
BEGIN TRANSACTION
Message 1
COMMIT TRANSACTION
`
	reader := bufio.NewScanner(strings.NewReader(input))
	mockClient := &MockTFTPClient{}
	address := "test_address"

	processTransactions(reader, mockClient, address)

	if mockClient.PutCallCount != 1 {
		t.Errorf("Expected Put to be called once")
	}

	if mockClient.PutURL != address {
		t.Errorf("Expected PutURL to be '%s', got '%s'", address, mockClient.PutURL)
	}

	expectedBatch := "Message 1\n"

	if mockClient.SentBatches[0] != expectedBatch {
		t.Errorf("Expected sent batch to be '%s', but got '%s'", expectedBatch, mockClient.SentBatches[0])
	}
}

func TestProcessTransactions_CommitOutsideTransactionIgnored(t *testing.T) {
	input := `COMMIT TRANSACTION
BEGIN TRANSACTION
Message 1
COMMIT TRANSACTION
`
	reader := bufio.NewScanner(strings.NewReader(input))
	mockClient := &MockTFTPClient{}
	address := "test_address"

	processTransactions(reader, mockClient, address)

	if mockClient.PutCallCount != 1 {
		t.Errorf("Expected Put to be called once")
	}

	if mockClient.PutURL != address {
		t.Errorf("Expected PutURL to be '%s', got '%s'", address, mockClient.PutURL)
	}

	expectedBatch := "Message 1\n"

	if mockClient.SentBatches[0] != expectedBatch {
		t.Errorf("Expected sent batch to be '%s', but got '%s'", expectedBatch, mockClient.SentBatches[0])
	}
}

func TestProcessTransactions_SingleMessage(t *testing.T) {
	input := `BEGIN TRANSACTION
Message 1
COMMIT TRANSACTION
`
	reader := bufio.NewScanner(strings.NewReader(input))
	mockClient := &MockTFTPClient{}
	address := "test_address"

	processTransactions(reader, mockClient, address)

	if mockClient.PutCallCount != 1 {
		t.Errorf("Expected Put to be called once")
	}

	if mockClient.PutURL != address {
		t.Errorf("Expected PutURL to be '%s', got '%s'", address, mockClient.PutURL)
	}

	expectedBatch := "Message 1\n"

	if mockClient.SentBatches[0] != expectedBatch {
		t.Errorf("Expected sent batch to be '%s', but got '%s'", expectedBatch, mockClient.SentBatches[0])
	}
}

func TestProcessTransactions_MultipleMessages(t *testing.T) {
	input := `BEGIN TRANSACTION
Message 1
Message 2
Message 3
COMMIT TRANSACTION
`
	reader := bufio.NewScanner(strings.NewReader(input))
	mockClient := &MockTFTPClient{}
	address := "test_address"

	processTransactions(reader, mockClient, address)

	if mockClient.PutCallCount != 1 {
		t.Errorf("Expected Put to be called once")
	}

	if mockClient.PutURL != address {
		t.Errorf("Expected PutURL to be '%s', got '%s'", address, mockClient.PutURL)
	}

	expectedBatch := "Message 1\nMessage 2\nMessage 3\n"

	if mockClient.SentBatches[0] != expectedBatch {
		t.Errorf("Expected sent batch to be '%s', but got '%s'", expectedBatch, mockClient.SentBatches[0])
	}
}

func TestProcessTransactions_MultipleTransactions(t *testing.T) {
	input := `BEGIN TRANSACTION
Message 1
COMMIT TRANSACTION
BEGIN TRANSACTION
Message 2
Message 3
COMMIT TRANSACTION
`
	reader := bufio.NewScanner(strings.NewReader(input))
	mockClient := &MockTFTPClient{}
	address := "test_address"

	processTransactions(reader, mockClient, address)

	if mockClient.PutCallCount != 2 {
		t.Errorf("Expected Put to be called twice")
	}

	if mockClient.PutURL != address {
		t.Errorf("Expected PutURL to be '%s', got '%s'", address, mockClient.PutURL)
	}

	firstExpectedBatch := "Message 1\n"
	secondExpectedBatch := "Message 2\nMessage 3\n"

	if mockClient.SentBatches[0] != firstExpectedBatch {
		t.Errorf("Expected first sent batch to be '%s', but got '%s'", firstExpectedBatch, mockClient.SentBatches[0])
	}

	if mockClient.SentBatches[1] != secondExpectedBatch {
		t.Errorf("Expected second sent batch to be '%s', but got '%s'", secondExpectedBatch, mockClient.SentBatches[1])
	}
}
