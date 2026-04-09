package utils

import (
	"fmt"
	"net/smtp"
	"os"
)

func SendOTPEmail(targetEmail string, otp string) error {
	// Ambil data dari .env
	from := os.Getenv("SMTP_USER")
	password := os.Getenv("SMTP_PASS")
	smtpHost := "smtp.gmail.com"
	smtpPort := "587"

	// Susun Pesan
	subject := "Subject: Reset Password Resolv IT\n"
	body := fmt.Sprintf("Halo,\n\nKode OTP untuk reset password Anda adalah: %s\n\nKode ini akan kadaluarsa dalam 5 menit. Jangan berikan kode ini kepada siapapun.", otp)
	message := []byte(subject + "\n" + body)

	// Autentikasi ke Google
	auth := smtp.PlainAuth("", from, password, smtpHost)

	// Kirim Email
	err := smtp.SendMail(smtpHost+":"+smtpPort, auth, from, []string{targetEmail}, message)
	if err != nil {
		return err
	}
	return nil
}
