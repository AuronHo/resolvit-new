package controllers

import (
	"itsolution-backend/config"
	"itsolution-backend/models"
	"net/http"

	"github.com/gin-gonic/gin"
)

// 1. Fungsi Toggle: Kalau belum disave -> Insert. Kalau sudah disave -> Delete.
func ToggleSaveService(c *gin.Context) {
	// Menangkap data JSON yang dikirim dari Flutter
	var requestBody struct {
		UserID int `json:"user_id"`
		JasaID int `json:"jasa_id"`
	}

	if err := c.ShouldBindJSON(&requestBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}

	var saved models.SavedService

	// Cek apakah data sudah ada di database
	result := config.DB.Where("user_id = ? AND jasa_id = ?", requestBody.UserID, requestBody.JasaID).First(&saved)

	if result.RowsAffected > 0 {
		// Jika SUDAH ADA, berarti user menekan tombol untuk UNSAVE (Hapus)
		config.DB.Delete(&saved)
		c.JSON(http.StatusOK, gin.H{"message": "Service removed from saved"})
	} else {
		// Jika BELUM ADA, berarti user menekan tombol untuk SAVE (Tambah)
		newSave := models.SavedService{
			UserID: requestBody.UserID,
			JasaID: requestBody.JasaID,
		}
		config.DB.Create(&newSave)
		c.JSON(http.StatusOK, gin.H{"message": "Service saved successfully"})
	}
}

// 2. Fungsi Mengambil Daftar Saved Services untuk layar SavedScreen
func GetSavedServices(c *gin.Context) {
	userID := c.Query("user_id")

	var services []models.Service

	// INNER JOIN: Ambil detail jasa dari tabel 'services' yang ID-nya ada di tabel 'saved_services' milik user_id ini
	err := config.DB.Table("services").
		Select("services.*").
		Joins("JOIN saved_services ON saved_services.jasa_id = services.\"JasaID\"").
		Where("saved_services.user_id = ?", userID).
		Find(&services).Error

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Saved services fetched successfully",
		"results": services,
	})
}
