package models

import "time"

type User struct {
	ID                 uint       `gorm:"primaryKey" json:"id"`
	Name               string     `json:"name"`
	Email              string     `gorm:"unique" json:"email"`
	Password           string     `json:"-"`    // "-" artinya password tidak akan dikirim balik ke JSON (aman)
	Role               string     `json:"role"` // customer atau provider
	ResetPasswordToken string     `json:"reset_password_token"`
	TokenExpiry        *time.Time `json:"token_expiry"`
	CreatedAt          time.Time  `json:"created_at"`
}
