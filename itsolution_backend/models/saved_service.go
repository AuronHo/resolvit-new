package models

import "time"

type SavedService struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	UserID    int       `gorm:"column:user_id" json:"user_id"`
	JasaID    int       `gorm:"column:jasa_id" json:"jasa_id"`
	CreatedAt time.Time `gorm:"column:created_at" json:"created_at"`
}

func (SavedService) TableName() string {
	return "saved_services"
}
