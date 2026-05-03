package controllers

import (
	"itsolution-backend/config"
	"itsolution-backend/models"
	"itsolution-backend/utils"
	"net/http"

	"github.com/gin-gonic/gin"
)

func GetUserProfile(c *gin.Context) {
	id := c.Param("id")
	var user models.User

	if err := config.DB.First(&user, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User tidak ditemukan"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"user": user})
}

func UpdateUserProfile(c *gin.Context) {
	id := c.Param("id")

	var input struct {
		Name      string `json:"name"`
		Phone     string `json:"phone"`
		AvatarUrl string `json:"avatar_url"`
	}
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid input"})
		return
	}

	updates := map[string]interface{}{}
	if input.Name != "" {
		updates["name"] = input.Name
	}
	if input.Phone != "" {
		updates["phone"] = input.Phone
	}
	if input.AvatarUrl != "" {
		updates["avatar_url"] = input.AvatarUrl
	}

	if err := config.DB.Model(&models.User{}).Where("id = ?", id).Updates(updates).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update profile"})
		return
	}

	var user models.User
	config.DB.First(&user, id)
	c.JSON(http.StatusOK, gin.H{"message": "Profile updated", "user": user})
}

func UpgradeToProvider(c *gin.Context) {
	var input struct {
		BusinessName  string `json:"business_name"`
		BusinessEmail string `json:"business_email"`
		Password      string `json:"password"`
		RegistrantID  int    `json:"registrant_id"` // logged-in customer's user ID
	}
	if err := c.ShouldBindJSON(&input); err != nil || input.BusinessName == "" || input.BusinessEmail == "" || input.Password == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "business_name, business_email, and password are required"})
		return
	}

	var existing models.User
	if config.DB.Where("email = ?", input.BusinessEmail).First(&existing).Error == nil {
		// Email already exists — upgrade that account to provider
		config.DB.Model(&existing).Updates(map[string]interface{}{
			"role": "provider",
			"name": input.BusinessName,
		})
		providerID := int(existing.ID)
		// If registrant is different account, link them
		if input.RegistrantID != 0 && input.RegistrantID != int(existing.ID) {
			config.DB.Model(&models.User{}).Where("id = ?", input.RegistrantID).
				Update("linked_provider_id", providerID)
		}
		c.JSON(http.StatusOK, gin.H{"message": "Account upgraded to provider", "user_id": existing.ID})
		return
	}

	hashedPwd, err := utils.HashPassword(input.Password)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to process password"})
		return
	}

	user := models.User{
		Name:     input.BusinessName,
		Email:    input.BusinessEmail,
		Password: hashedPwd,
		Role:     "provider",
	}
	if err := config.DB.Create(&user).Error; err != nil {
		c.JSON(http.StatusConflict, gin.H{"error": "Email sudah terdaftar"})
		return
	}

	// Link new provider account back to registrant's personal account
	if input.RegistrantID != 0 {
		providerID := int(user.ID)
		config.DB.Model(&models.User{}).Where("id = ?", input.RegistrantID).
			Update("linked_provider_id", providerID)
	}

	c.JSON(http.StatusCreated, gin.H{"message": "Provider account created", "user_id": user.ID})
}
