package models

import "time"

type ChatRoom struct {
	ID          uint      `gorm:"primaryKey" json:"id"`
	CustomerID  int       `json:"customer_id"`
	ProviderID  int       `json:"provider_id"`
	JasaID      int       `json:"jasa_id"`
	JasaName    string    `json:"jasa_name"`
	LastMessage string    `json:"last_message"`
	UpdatedAt   time.Time `json:"updated_at"`
	CreatedAt   time.Time `json:"created_at"`
}

type ChatMessage struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	RoomID    int       `json:"room_id"`
	SenderID  int       `json:"sender_id"`
	Content   string    `json:"content"`
	CreatedAt time.Time `json:"created_at"`
}
