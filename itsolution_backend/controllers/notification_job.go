package controllers

import (
	"fmt"
	"itsolution-backend/config"
	"itsolution-backend/models"
	"time"
)

// StartNotificationJob runs a daily check for inactive chats and sends
// a rating reminder to customers who haven't reviewed the service yet.
func StartNotificationJob() {
	// Run once at startup, then every 24 hours
	go func() {
		checkInactiveChats()
		ticker := time.NewTicker(24 * time.Hour)
		for range ticker.C {
			checkInactiveChats()
		}
	}()
}

func checkInactiveChats() {
	// Find rooms with no activity for 3+ days
	cutoff := time.Now().Add(-72 * time.Hour)

	var rooms []models.ChatRoom
	config.DB.Where("updated_at < ?", cutoff).Find(&rooms)

	for _, room := range rooms {
		// Skip if customer already reviewed this service
		var reviewCount int64
		config.DB.Model(&models.Review{}).
			Where("jasa_id = ? AND user_id = ?", room.JasaID, room.CustomerID).
			Count(&reviewCount)
		if reviewCount > 0 {
			continue
		}

		// Skip if we already sent a rate_reminder for this service to this user
		var notifCount int64
		config.DB.Model(&models.Notification{}).
			Where("user_id = ? AND type = ? AND ref_id = ?", room.CustomerID, "rate_reminder", room.JasaID).
			Count(&notifCount)
		if notifCount > 0 {
			continue
		}

		notif := models.Notification{
			UserID:      room.CustomerID,
			Title:       "How was your experience?",
			Description: fmt.Sprintf("Rate your experience with %s. Your feedback helps others find great service!", room.JasaName),
			Type:        "rate_reminder",
			RefID:       room.JasaID,
		}
		config.DB.Create(&notif)
	}
}
