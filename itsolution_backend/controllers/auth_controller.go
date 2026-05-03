package controllers

import (
	"fmt"
	"itsolution-backend/config"
	"itsolution-backend/models"
	"itsolution-backend/utils"
	"math/rand"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

func Register(c *gin.Context) {
	var input struct {
		Name     string `json:"name"`
		Email    string `json:"email"`
		Password string `json:"password"`
		Role     string `json:"role"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Data tidak lengkap atau salah format"})
		return
	}

	hashedPassword, err := utils.HashPassword(input.Password)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengamankan password"})
		return
	}

	user := models.User{
		Name:     input.Name,
		Email:    input.Email,
		Password: hashedPassword,
		Role:     input.Role,
	}

	result := config.DB.Create(&user)
	if result.Error != nil {
		c.JSON(http.StatusConflict, gin.H{"error": "email_already_registered"})
		return
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"user_id": user.ID,
		"role":    user.Role,
		"exp":     time.Now().Add(time.Hour * 24).Unix(),
	})
	tokenString, err := token.SignedString(config.GetJWTSecret())
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membuat token"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Registrasi berhasil!",
		"user_id": user.ID,
		"token":   tokenString,
	})
}

func Login(c *gin.Context) {
	var input struct {
		Email    string `json:"email"`
		Password string `json:"password"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Format data salah"})
		return
	}

	var user models.User
	if err := config.DB.Where("email = ?", input.Email).First(&user).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Email tidak ditemukan"})
		return
	}

	if !utils.CheckPasswordHash(input.Password, user.Password) {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Password salah"})
		return
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"user_id": user.ID,
		"role":    user.Role,
		"exp":     time.Now().Add(time.Hour * 24).Unix(),
	})

	tokenString, err := token.SignedString(config.GetJWTSecret())
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membuat token"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":            "Login berhasil!",
		"token":              tokenString,
		"user_id":            user.ID,
		"linked_provider_id": user.LinkedProviderID,
	})
}

func ForgotPassword(c *gin.Context) {
	var input struct {
		Email string `json:"email"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Email wajib diisi"})
		return
	}

	var user models.User
	if err := config.DB.Where("email = ?", input.Email).First(&user).Error; err != nil {
		c.JSON(http.StatusOK, gin.H{"message": "Jika email terdaftar, OTP akan dikirimkan"})
		return
	}

	rand.Seed(time.Now().UnixNano())
	otp := fmt.Sprintf("%06d", rand.Intn(1000000))

	expiry := time.Now().Add(5 * time.Minute)
	config.DB.Model(&user).Updates(models.User{
		ResetPasswordToken: otp,
		TokenExpiry:        &expiry,
	})

	err := utils.SendOTPEmail(user.Email, otp)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengirim email"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Kode OTP telah dikirim ke email Anda"})
}

func ResetPassword(c *gin.Context) {
	var input struct {
		Email       string `json:"email"`
		OTP         string `json:"otp"`
		NewPassword string `json:"new_password"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Input tidak valid"})
		return
	}

	var user models.User
	err := config.DB.Where("email = ? AND reset_password_token = ?", input.Email, input.OTP).First(&user).Error
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Email atau kode OTP salah"})
		return
	}

	if user.TokenExpiry != nil && time.Now().After(*user.TokenExpiry) {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Kode OTP sudah kadaluarsa"})
		return
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(input.NewPassword), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memproses password baru"})
		return
	}

	err = config.DB.Model(&user).Updates(map[string]interface{}{
		"password":             string(hashedPassword),
		"reset_password_token": nil,
		"token_expiry":         nil,
	}).Error
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengupdate password"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Password berhasil diperbarui! Silakan login menggunakan password baru Anda."})
}

func VerifyOTP(c *gin.Context) {
	var input struct {
		Email string `json:"email"`
		OTP   string `json:"otp"`
	}
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid input"})
		return
	}

	var user models.User
	err := config.DB.Where("email = ? AND reset_password_token = ?", input.Email, input.OTP).First(&user).Error
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid OTP code"})
		return
	}

	if user.TokenExpiry != nil && time.Now().After(*user.TokenExpiry) {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "OTP expired"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "OTP Verified"})
}

func SyncGoogleUser(c *gin.Context) {
	var input struct {
		Name      string `json:"name"`
		Email     string `json:"email"`
		AvatarUrl string `json:"avatar_url"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var user models.User
	result := config.DB.Where("email = ?", input.Email).FirstOrCreate(&user, models.User{
		Name:      input.Name,
		Email:     input.Email,
		AvatarUrl: input.AvatarUrl,
		Role:      "customer",
	})

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal sinkronisasi data user"})
		return
	}

	// Also generate JWT so Google users have a token
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"user_id": user.ID,
		"role":    user.Role,
		"exp":     time.Now().Add(time.Hour * 24).Unix(),
	})
	tokenString, _ := token.SignedString(config.GetJWTSecret())

	c.JSON(http.StatusOK, gin.H{
		"message": "Login berhasil",
		"user":    user,
		"token":   tokenString,
	})
}
