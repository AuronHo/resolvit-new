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
	userID := 1 // Dummy User ID (Nanti diganti dinamis saat fitur Login selesai)

	// LOGIKA SAMA, HANYA DITAMBAH SELECT & LEFT JOIN
	err := config.DB.Table("services").
		Select("services.*, CASE WHEN saved_services.id IS NOT NULL THEN true ELSE false END as \"IsBookmarked\"").
		Joins("LEFT JOIN saved_services ON services.\"JasaID\" = saved_services.jasa_id AND saved_services.user_id = ?", userID).
		Order("services.\"RatingRataRata\" DESC"). // Tambahkan prefix services. agar tidak ambigu
		Limit(5).
		Find(&services).Error

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch recommendations"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Recommendations fetched successfully",
		"results": services,
	})
}

func GetServicesByCategory(c *gin.Context) {
	categoryName := c.Query("name")

	// LOGIKA PAGINATION KAMU SAMA SEKALI TIDAK DIUBAH
	pageStr := c.DefaultQuery("page", "1")
	page, _ := strconv.Atoi(pageStr)
	limit := 10
	offset := (page - 1) * limit

	var services []models.Service
	userID := 1 // Dummy User ID

	// LOGIKA SAMA, HANYA DITAMBAH SELECT & LEFT JOIN
	err := config.DB.Table("services").
		Select("services.*, CASE WHEN saved_services.id IS NOT NULL THEN true ELSE false END as \"IsBookmarked\"").
		Joins("LEFT JOIN saved_services ON services.\"JasaID\" = saved_services.jasa_id AND saved_services.user_id = ?", userID).
		Where("services.\"Kategori\" = ?", categoryName). // Tambahkan prefix services.
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
