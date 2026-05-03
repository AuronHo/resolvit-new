package config

import "os"

func GetJWTSecret() []byte {
	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		return []byte("rahasia_skripsi_auron_123")
	}
	return []byte(secret)
}
