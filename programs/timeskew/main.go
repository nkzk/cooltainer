package main

import (
	"encoding/binary"
	"fmt"
	"log"
	"net"
	"time"
)

// NTP constants
const (
	ntpEpochOffset = 2208988800 // NTP epoch starts on 1900, UNIX epoch starts in 1970
  url = "pool.ntp.org"
)

// Function to query the NTP server
func queryNTPServer(server string) (time.Time, error) {
	// Connect to the NTP server
	conn, err := net.Dial("udp", server+":123")
	if err != nil {
		return time.Time{}, fmt.Errorf("error connecting to NTP server: %v", err)
	}
	defer conn.Close()

	// Create the NTP request packet (48 bytes with the first byte set to 0x1B)
	req := make([]byte, 48)
	req[0] = 0x1B

	// Send the request packet to the NTP server
	if _, err := conn.Write(req); err != nil {
		return time.Time{}, fmt.Errorf("error sending request to NTP server: %v", err)
	}

	// Receive the response packet from the NTP server
	resp := make([]byte, 48)
	if _, err := conn.Read(resp); err != nil {
		return time.Time{}, fmt.Errorf("error reading response from NTP server: %v", err)
	}

	// Extract the transmit timestamp from the response (bytes 40-47)
	secs := binary.BigEndian.Uint32(resp[40:44])
	frac := binary.BigEndian.Uint32(resp[44:48])

	// Convert NTP time to UNIX time by subtracting the NTP epoch offset
	ntpTime := float64(secs) - ntpEpochOffset + (float64(frac) / (1 << 32))

	// Convert to Go time.Time type
	return time.Unix(int64(ntpTime), int64((ntpTime-float64(int64(ntpTime)))*1e9)), nil
}

func main() {
	// Get the current local system time
	localTime := time.Now()

	// Query the NTP server for the time
	ntpTime, err := queryNTPServer(url)
	if err != nil {
		log.Fatalf("Error querying NTP server: %v\n", err)
	}

	// Calculate the time skew
	timeSkew := localTime.Sub(ntpTime)

	// Print the results
	fmt.Printf("Local Time: %v\n", localTime)
	fmt.Printf("NTP Time:   %v\n", ntpTime)
	fmt.Printf("Time Skew:  %v\n", timeSkew)

	// Set a threshold for acceptable skew (e.g., 1 second)
	threshold := 1 * time.Second
	if timeSkew > threshold || timeSkew < -threshold {
		fmt.Printf("WARNING: Time skew is greater than %v\n", threshold)
	} else {
		fmt.Println("Time skew is within acceptable limits.")
	}
}
