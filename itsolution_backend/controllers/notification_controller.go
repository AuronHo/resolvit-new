package controllers

import (
	"itsolution-backend/config"
	"itsolution-backend/models"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

func GetNotifications(c *gin.Context) {
	userIDStr := c.Query("user_id")
	userID, err := strconv.Atoi(userIDStr)
	if err != nil || userID == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "user_id is required"})
		return
	}

	// For rate_reminder notifications, join services to always use the current
	// service name and avatar instead of the stale values stored at creation time.
	sql := `
		SELECT
			n.id, n.user_id, n.is_read, n.type, n.ref_id, n.created_at,
			CASE WHEN n.type = 'rate_reminder'
				THEN 'How was your experience?'
				ELSE n.title
			END AS title,
			CASE WHEN n.type = 'rate_reminder'
				THEN 'Rate your experience with ' ||
				     COALESCE(NULLIF(s."NamaJasa", ''), 'this service') ||
				     '. Your feedback helps others find great service!'
				ELSE n.description
			END AS description,
			CASE WHEN n.type = 'rate_reminder'
				THEN COALESCE(NULLIF(s.image_url, ''), u.avatar_url, '')
				ELSE n.avatar_url
			END AS avatar_url
		FROM notifications n
		LEFT JOIN services s ON n.type = 'rate_reminder' AND s."JasaID" = n.ref_id
		LEFT JOIN users u ON s."ProviderID" = u.id
		WHERE n.user_id = ?
		ORDER BY n.created_at DESC
	`
	var notifications []models.Notification
	if err := config.DB.Raw(sql, userID).Scan(&notifications).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to load notifications"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"results": notifications})
}

func MarkNotificationRead(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid notification ID"})
		return
	}

	config.DB.Model(&models.Notification{}).Where("id = ?", id).Update("is_read", true)
	c.JSON(http.StatusOK, gin.H{"message": "Marked as read"})
}
