package controllers

import (
	"context"
	"itsolution-backend/config"
	"itsolution-backend/models"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"google.golang.org/api/idtoken"
)

var googleClientID = "331772422234-7v78imkrihg9fgajvk9hf5qasneu3vdg.apps.googleusercontent.com"

func GoogleLogin(c *gin.Context) {
	var input struct {
		IDToken string `json:"id_token"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID Token dibutuhkan"})
		return
	}

	payload, err := idtoken.Validate(context.Background(), input.IDToken, googleClientID)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Token Google tidak valid"})
		return
	}

	email := payload.Claims["email"].(string)
	name := payload.Claims["name"].(string)

	var user models.User
	if err := config.DB.Where("email = ?", email).First(&user).Error; err != nil {
		user = models.User{
			Name:  name,
			Email: email,
			Role:  "customer",
		}
		config.DB.Create(&user)
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"user_id": user.ID,
		"role":    user.Role,
		"exp":     time.Now().Add(time.Hour * 24).Unix(),
	})

	tokenString, _ := token.SignedString(config.GetJWTSecret())

	c.JSON(http.StatusOK, gin.H{
		"message": "Login Google Berhasil!",
		"token":   tokenString,
		"user_id": user.ID,
	})
}
