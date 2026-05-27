package utils

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
)

func SendOTPEmail(targetEmail string, otp string) error {
	apiKey := os.Getenv("RESEND_API_KEY")

	// DEV MODE: no key → print OTP to console
	if apiKey == "" {
		fmt.Printf("[DEV] OTP for %s: %s\n", targetEmail, otp)
		return nil
	}

	from := os.Getenv("RESEND_FROM")
	if from == "" {
		from = "onboarding@resend.dev" // default Resend test address
	}

	payload := map[string]interface{}{
		"from":    from,
		"to":      []string{targetEmail},
		"subject": "Reset Password Resolv IT",
		"text": fmt.Sprintf(
			"Halo,\n\nKode OTP untuk reset password Anda adalah: %s\n\nKode ini akan kadaluarsa dalam 5 menit. Jangan berikan kode ini kepada siapapun.",
			otp,
		),
	}

	body, err := json.Marshal(payload)
	if err != nil {
		return err
	}

	req, err := http.NewRequest("POST", "https://api.resend.com/emails", bytes.NewBuffer(body))
	if err != nil {
		return err
	}
	req.Header.Set("Authorization", "Bearer "+apiKey)
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 400 {
		return fmt.Errorf("resend API error: status %d", resp.StatusCode)
	}
	return nil
}
