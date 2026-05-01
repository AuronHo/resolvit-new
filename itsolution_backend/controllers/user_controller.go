package controllers

import (
	"itsolution-backend/config"
	"itsolution-backend/models"
	"net/http"

	"github.com/gin-gonic/gin"
)

func GetUserProfile(c *gin.Context) {
	id := c.Param("id")
	var user models.User

	// Cari user berdasarkan ID
	if err := config.DB.First(&user, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User tidak ditemukan"})
		return
	}

	// Karena Password di model sudah menggunakan json:"-",
	// password tidak akan ikut terkirim ke Flutter. Sangat aman!
	c.JSON(http.StatusOK, gin.H{"user": user})
}
