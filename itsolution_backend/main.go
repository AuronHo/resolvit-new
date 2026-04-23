package main

import (
	"itsolution-backend/config"
	"itsolution-backend/controllers"
	"itsolution-backend/middlewares"
	"itsolution-backend/models"
	"net/http"

	"github.com/gin-gonic/gin"
)

func main() {
	// 1. Koneksi Database & Migrate
	config.ConnectDatabase()
	config.DB.AutoMigrate(&models.User{})

	// 2. Inisialisasi Router Gin
	r := gin.Default()

	// AREA PUBLIK (Tidak butuh tiket)
	r.GET("/ping", func(c *gin.Context) { c.JSON(200, gin.H{"message": "Pong!"}) })
	r.POST("/api/register", controllers.Register)
	r.POST("/api/login", controllers.Login)
	r.POST("/api/auth/google", controllers.GoogleLogin)
	r.POST("/api/forgot-password", controllers.ForgotPassword)
	r.POST("/api/reset-password", controllers.ResetPassword)
	r.POST("/api/verify-otp", controllers.VerifyOTP)
	r.GET("/api/services/recommendations", controllers.GetRecommendations)
	r.GET("/api/services/category", controllers.GetServicesByCategory)

	// AREA VIP (Dijaga oleh Middleware)
	// Perhatikan: Kita selipkan "middlewares.RequireAuth" sebelum fungsi utama
	r.GET("/api/profile", middlewares.RequireAuth, func(c *gin.Context) {
		// Mengambil ID user dari token yang sudah dicek satpam
		userID, _ := c.Get("user_id")
		role, _ := c.Get("role")

		c.JSON(http.StatusOK, gin.H{
			"message": "Selamat datang di Area VIP rahasia!",
			"user_id": userID,
			"role":    role,
		})
	})

	// 4. Jalankan Server
	r.Run(":8080")
}
