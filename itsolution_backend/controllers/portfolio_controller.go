package controllers

import (
	"itsolution-backend/config"
	"itsolution-backend/models"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

func CreatePost(c *gin.Context) {
	var input struct {
		ProviderID int    `json:"provider_id"`
		Caption    string `json:"caption"`
		ImageUrl   string `json:"image_url"`
	}
	if err := c.ShouldBindJSON(&input); err != nil || input.ProviderID == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "provider_id required"})
		return
	}
	post := models.PortfolioPost{
		ProviderID: input.ProviderID,
		Caption:    input.Caption,
		ImageUrl:   input.ImageUrl,
	}
	if err := config.DB.Create(&post).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create post"})
		return
	}
	c.JSON(http.StatusCreated, gin.H{"post": post})
}

func GetPosts(c *gin.Context) {
	providerIDStr := c.Query("provider_id")
	providerID, err := strconv.Atoi(providerIDStr)
	if err != nil || providerID == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "provider_id required"})
		return
	}
	var posts []models.PortfolioPost
	config.DB.Where("provider_id = ?", providerID).Order("created_at DESC").Find(&posts)
	c.JSON(http.StatusOK, gin.H{"posts": posts})
}
