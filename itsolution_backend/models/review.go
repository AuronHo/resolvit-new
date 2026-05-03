package models

import "time"

type Review struct {
	ID         uint      `gorm:"primaryKey" json:"id"`
	JasaID     int       `json:"jasa_id"`
	UserID     int       `json:"user_id"`
	UserName   string    `json:"user_name"`
	UserAvatar string    `json:"user_avatar"`
	Rating     int       `json:"rating"`
	Comment    string    `json:"comment"`
	ImageUrl   string    `json:"image_url"`
	CreatedAt  time.Time `json:"created_at"`
}
