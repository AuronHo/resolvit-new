package main

import (
	"itsolution-backend/config"
	"itsolution-backend/controllers"
	"itsolution-backend/middlewares"
	"itsolution-backend/models"
	"net/http"

	"github.com/gin-gonic/gin"
)

func corsMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set("Access-Control-Allow-Credentials", "true")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization, Accept")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS")
		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(http.StatusNoContent)
			return
		}
		c.Next()
	}
}

func main() {
	config.ConnectDatabase()

	// Enable pg_trgm for fuzzy search
	config.DB.Exec("CREATE EXTENSION IF NOT EXISTS pg_trgm")

	// Migrate all models
	config.DB.AutoMigrate(
		&models.User{},
		&models.Review{},
		&models.ChatRoom{},
		&models.ChatMessage{},
		&models.Notification{},
	)

	r := gin.Default()
	r.Use(corsMiddleware())

	// --- PUBLIC ROUTES ---
	r.GET("/ping", func(c *gin.Context) { c.JSON(200, gin.H{"message": "Pong!"}) })

	// Auth
	r.POST("/api/register", controllers.Register)
	r.POST("/api/login", controllers.Login)
	r.POST("/api/auth/google", controllers.GoogleLogin)
	r.POST("/api/auth/sync", controllers.SyncGoogleUser)
	r.POST("/api/forgot-password", controllers.ForgotPassword)
	r.POST("/api/reset-password", controllers.ResetPassword)
	r.POST("/api/verify-otp", controllers.VerifyOTP)

	// Provider registration
	r.POST("/api/register/provider", controllers.UpgradeToProvider)

	// Users
	r.GET("/api/users/:id", controllers.GetUserProfile)
	r.PUT("/api/users/:id", controllers.UpdateUserProfile)

	// Avatar upload
	r.POST("/api/upload/avatar", controllers.UploadAvatar)

	// Services
	r.GET("/api/services/recommendations", controllers.GetRecommendations)
	r.GET("/api/services/category", controllers.GetServicesByCategory)
	r.POST("/api/services", controllers.CreateService)
	r.POST("/api/services/save", controllers.ToggleSaveService)
	r.GET("/api/services/saved", controllers.GetSavedServices)

	// Search (replaces Python backend)
	r.GET("/api/search", controllers.SearchServices)

	// Reviews
	r.GET("/api/services/:id/reviews", controllers.GetReviews)
	r.POST("/api/services/:id/reviews", controllers.PostReview)

	// Chat (REST)
	r.POST("/api/chats", controllers.GetOrCreateChatRoom)
	r.GET("/api/chats", controllers.GetChatRooms)
	r.GET("/api/chats/:room_id/messages", controllers.GetChatMessages)

	// Notifications
	r.GET("/api/notifications", controllers.GetNotifications)
	r.PUT("/api/notifications/:id/read", controllers.MarkNotificationRead)

	// --- WEBSOCKET ---
	r.GET("/ws/chat/:room_id", controllers.ChatWebSocket)

	// --- PROTECTED ROUTES ---
	r.GET("/api/profile", middlewares.RequireAuth, func(c *gin.Context) {
		userID, _ := c.Get("user_id")
		role, _ := c.Get("role")
		c.JSON(http.StatusOK, gin.H{
			"message": "Selamat datang di Area VIP rahasia!",
			"user_id": userID,
			"role":    role,
		})
	})

	r.Run(":8080")
}
