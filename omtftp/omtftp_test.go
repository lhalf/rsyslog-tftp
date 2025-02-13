package main

import (
	"bufio"
	"io"
	"strings"
	"testing"
)

type MockTFTPClient struct {
	PutCalled    bool
	PutURL       string
	PutReader    io.Reader
	PutSize      int64
	PutError     error
	ReceivedData string
	CallCount    int
}

func (m *MockTFTPClient) Put(url string, reader io.Reader, size int64) (err error) {
	m.PutCalled = true
	m.PutURL = url
	m.PutReader = reader
	m.PutSize = size
	m.CallCount++

	if reader != nil {
		data, err := io.ReadAll(reader)
		if err != nil {
			return err
		}
		m.ReceivedData = string(data)
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

	if mockClient.PutCalled {
		t.Errorf("Expected Put to not be called")
	}
}

func TestProcessTransactions_MultipleBeginsIgnored(t *testing.T) {
	input := `BEGIN TRANSACTION
BEGIN TRANSACTION
Message 1
COMMIT TRANSACTION
`
	reader := bufio.NewScanner(strings.NewReader(input))
	mockClient := &MockTFTPClient{}
	address := "test_address"

	processTransactions(reader, mockClient, address)

	if !mockClient.PutCalled {
		t.Errorf("Expected Put to be called")
	}

	if mockClient.PutURL != address {
		t.Errorf("Expected PutURL to be '%s', got '%s'", address, mockClient.PutURL)
	}

	expectedData := "Message 1\n"

	if mockClient.ReceivedData != expectedData {
		t.Errorf("Expected PutReader data to be '%s', but got '%s'", expectedData, mockClient.ReceivedData)
	}

	if mockClient.PutSize != 0 {
		t.Errorf("Expected PutSize to be 0, but got %d", mockClient.PutSize)
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

	if !mockClient.PutCalled {
		t.Errorf("Expected Put to be called")
	}

	if mockClient.PutURL != address {
		t.Errorf("Expected PutURL to be '%s', got '%s'", address, mockClient.PutURL)
	}

	expectedData := "Message 1\n"

	if mockClient.ReceivedData != expectedData {
		t.Errorf("Expected PutReader data to be '%s', but got '%s'", expectedData, mockClient.ReceivedData)
	}

	if mockClient.PutSize != 0 {
		t.Errorf("Expected PutSize to be 0, but got %d", mockClient.PutSize)
	}
}
