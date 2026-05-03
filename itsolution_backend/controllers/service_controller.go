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

	userID := c.Query("user_id")
	if userID == "" {
		userID = "0" // Jika tidak ada yang login, anggap ID 0 (tidak ada bookmark)
	}

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

func CreateService(c *gin.Context) {
	var input struct {
		ProviderID    int    `json:"provider_id"`
		NamaJasa      string `json:"NamaJasa"`
		Kategori      string `json:"Kategori"`
		DeskripsiJasa string `json:"DeskripsiJasa"`
		HargaMulai    int64  `json:"HargaMulai"`
	}
	if err := c.ShouldBindJSON(&input); err != nil || input.ProviderID == 0 || input.NamaJasa == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "provider_id and NamaJasa are required"})
		return
	}

	service := models.Service{
		ProviderID:    input.ProviderID,
		NamaJasa:      input.NamaJasa,
		Kategori:      input.Kategori,
		DeskripsiJasa: input.DeskripsiJasa,
		HargaMulai:    input.HargaMulai,
		IsOpen:        true,
	}
	if err := config.DB.Create(&service).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create service"})
		return
	}
	c.JSON(http.StatusCreated, gin.H{"message": "Service created", "service": service})
}

func GetServicesByCategory(c *gin.Context) {
	categoryName := c.Query("name")

	// LOGIKA PAGINATION KAMU SAMA SEKALI TIDAK DIUBAH
	pageStr := c.DefaultQuery("page", "1")
	page, _ := strconv.Atoi(pageStr)
	limit := 10
	offset := (page - 1) * limit

	var services []models.Service
	userID := c.Query("user_id")
	if userID == "" {
		userID = "0" // Jika tidak ada yang login, anggap ID 0 (tidak ada bookmark)
	}

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
