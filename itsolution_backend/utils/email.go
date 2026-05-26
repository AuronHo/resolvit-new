package utils

import (
	"crypto/tls"
	"fmt"
	"net"
	"net/smtp"
	"os"
)

func SendOTPEmail(targetEmail string, otp string) error {
	from := os.Getenv("SMTP_USER")
	password := os.Getenv("SMTP_PASS")

	// DEV MODE: no credentials → print OTP to console
	if from == "" || password == "" {
		fmt.Printf("[DEV] OTP for %s: %s\n", targetEmail, otp)
		return nil
	}

	host := "smtp.gmail.com"
	port := "465"

	tlsConfig := &tls.Config{ServerName: host}

	conn, err := tls.Dial("tcp", net.JoinHostPort(host, port), tlsConfig)
	if err != nil {
		return fmt.Errorf("tls dial: %w", err)
	}
	defer conn.Close()

	client, err := smtp.NewClient(conn, host)
	if err != nil {
		return fmt.Errorf("smtp client: %w", err)
	}
	defer client.Quit()

	auth := smtp.PlainAuth("", from, password, host)
	if err = client.Auth(auth); err != nil {
		return fmt.Errorf("smtp auth: %w", err)
	}

	if err = client.Mail(from); err != nil {
		return err
	}
	if err = client.Rcpt(targetEmail); err != nil {
		return err
	}

	wc, err := client.Data()
	if err != nil {
		return err
	}

	msg := fmt.Sprintf(
		"From: %s\r\nTo: %s\r\nSubject: Reset Password Resolv IT\r\n\r\nHalo,\r\n\r\nKode OTP untuk reset password Anda adalah: %s\r\n\r\nKode ini akan kadaluarsa dalam 5 menit.",
		from, targetEmail, otp,
	)
	if _, err = fmt.Fprint(wc, msg); err != nil {
		return err
	}
	return wc.Close()
}
