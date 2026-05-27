package utils

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
)

func SendOTPEmail(targetEmail string, otp string) error {
	apiKey := os.Getenv("MAILJET_API_KEY")
	secretKey := os.Getenv("MAILJET_SECRET_KEY")
	fromEmail := os.Getenv("MAILJET_FROM_EMAIL")

	// DEV MODE: no credentials → print OTP to console
	if apiKey == "" || secretKey == "" {
		fmt.Printf("[DEV] OTP for %s: %s\n", targetEmail, otp)
		return nil
	}

	if fromEmail == "" {
		fromEmail = "noreply@resolvit.com"
	}

	payload := map[string]interface{}{
		"Messages": []map[string]interface{}{
			{
				"From": map[string]string{
					"Email": fromEmail,
					"Name":  "Resolv IT",
				},
				"To": []map[string]string{
					{"Email": targetEmail},
				},
				"Subject": "Reset Password Resolv IT",
				"TextPart": fmt.Sprintf(
					"Halo,\n\nKode OTP untuk reset password Anda adalah: %s\n\nKode ini akan kadaluarsa dalam 5 menit. Jangan berikan kode ini kepada siapapun.",
					otp,
				),
			},
		},
	}

	body, err := json.Marshal(payload)
	if err != nil {
		return err
	}

	req, err := http.NewRequest("POST", "https://api.mailjet.com/v3.1/send", bytes.NewBuffer(body))
	if err != nil {
		return err
	}
	req.SetBasicAuth(apiKey, secretKey)
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 400 {
		return fmt.Errorf("mailjet error: status %d", resp.StatusCode)
	}
	return nil
}
