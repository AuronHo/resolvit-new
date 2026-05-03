package models

import "time"

type Notification struct {
	ID          uint      `gorm:"primaryKey" json:"id"`
	UserID      int       `json:"user_id"`
	Title       string    `json:"title"`
	Description string    `json:"description"`
	IsRead      bool      `json:"is_read" gorm:"default:false"`
	AvatarUrl   string    `json:"avatar_url"`
	Type        string    `json:"type" gorm:"default:''"`
	RefID       int       `json:"ref_id" gorm:"default:0"`
	CreatedAt   time.Time `json:"created_at"`
}
