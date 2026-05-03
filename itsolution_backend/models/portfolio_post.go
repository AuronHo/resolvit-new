package models

import "time"

type PortfolioPost struct {
	ID         uint      `gorm:"primaryKey" json:"id"`
	ProviderID int       `gorm:"column:provider_id;index" json:"provider_id"`
	Caption    string    `gorm:"column:caption" json:"caption"`
	ImageUrl   string    `gorm:"column:image_url" json:"image_url"`
	CreatedAt  time.Time `gorm:"column:created_at" json:"created_at"`
}
