package controllers

import (
	"itsolution-backend/config"
	"itsolution-backend/models"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

func GetReviews(c *gin.Context) {
	jasaIDStr := c.Param("id")
	jasaID, err := strconv.Atoi(jasaIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid service ID"})
		return
	}

	var reviews []models.Review
	config.DB.Where("jasa_id = ?", jasaID).
		Order("created_at DESC").
		Find(&reviews)

	c.JSON(http.StatusOK, gin.H{"results": reviews})
}

func PostReview(c *gin.Context) {
	jasaIDStr := c.Param("id")
	jasaID, err := strconv.Atoi(jasaIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid service ID"})
		return
	}

	var input struct {
		UserID  int    `json:"user_id"`
		Rating  int    `json:"rating"`
		Comment string `json:"comment"`
	}
	if err := c.ShouldBindJSON(&input); err != nil || input.UserID == 0 || input.Rating < 1 || input.Rating > 5 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "user_id, rating (1-5), and comment are required"})
		return
	}

	// Get user info for display
	var user models.User
	config.DB.First(&user, input.UserID)

	review := models.Review{
		JasaID:     jasaID,
		UserID:     input.UserID,
		UserName:   user.Name,
		UserAvatar: user.AvatarUrl,
		Rating:     input.Rating,
		Comment:    input.Comment,
	}
	config.DB.Create(&review)

	// Update average rating on service
	var avgRating float64
	config.DB.Model(&models.Review{}).
		Where("jasa_id = ?", jasaID).
		Select("COALESCE(AVG(rating), 0)").
		Scan(&avgRating)

	config.DB.Exec(`UPDATE services SET "RatingRataRata" = ? WHERE "JasaID" = ?`, avgRating, jasaID)

	c.JSON(http.StatusCreated, gin.H{"message": "Review submitted", "review": review})
}
