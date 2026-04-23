package controllers

import (
	"itsolution-backend/config"
	"itsolution-backend/models"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

// Change this to your actual config import path
// Change this to your actual models import path

// GetRecommendations fetches top-rated services for the Home Screen
func GetRecommendations(c *gin.Context) {
	var services []models.Service

	// Fetch 5 services, ordered by the highest rating
	err := config.DB.Order("\"RatingRataRata\" DESC").Limit(5).Find(&services).Error

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch recommendations"})
		return
	}

	// We wrap it in the exact JSON format your Flutter app is expecting
	c.JSON(http.StatusOK, gin.H{
		"message": "Recommendations fetched successfully",
		"results": services,
	})
}

func GetServicesByCategory(c *gin.Context) {
	categoryName := c.Query("name")

	// Default page 1, limit 10 data per request
	pageStr := c.DefaultQuery("page", "1")
	page, _ := strconv.Atoi(pageStr)
	limit := 10
	offset := (page - 1) * limit

	var services []models.Service

	// Tambahkan .Limit() dan .Offset() di GORM
	err := config.DB.Where("\"Kategori\" = ?", categoryName).
		Limit(limit).
		Offset(offset).
		Find(&services).Error

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch services"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Services fetched successfully",
		"results": services,
	})
}
