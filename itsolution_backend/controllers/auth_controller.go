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

var jwtSecret = []byte("rahasia_skripsi_auron_123")

// Fungsi Register untuk mendaftarkan user baru
func Register(c *gin.Context) {
	// 1. Tangkap data JSON yang dikirim dari Postman/Flutter
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

	// 2. Acak passwordnya menggunakan Utils yang sudah kita buat
	hashedPassword, err := utils.HashPassword(input.Password)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengamankan password"})
		return
	}

	// 3. Masukkan data ke dalam "Cetakan" Model User
	user := models.User{
		Name:     input.Name,
		Email:    input.Email,
		Password: hashedPassword,
		Role:     input.Role,
	}

	// 4. Suruh GORM menyimpan data tersebut ke Supabase
	result := config.DB.Create(&user)

	// Jika error (misal email sudah pernah didaftarkan)
	if result.Error != nil {
		c.JSON(http.StatusConflict, gin.H{"error": "Email sudah terdaftar!"})
		return
	}

	// 5. Beri tahu Postman/Flutter bahwa sukses
	c.JSON(http.StatusOK, gin.H{
		"message": "Registrasi berhasil!",
		"user_id": user.ID,
	})
}

func Login(c *gin.Context) {
	var input struct {
		Email    string `json:"email"`
		Password string `json:"password"`
	}

	// 1. Tangkap email dan password dari Postman/Flutter
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Format data salah"})
		return
	}

	// 2. Cek apakah email ada di Supabase
	var user models.User
	if err := config.DB.Where("email = ?", input.Email).First(&user).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Email tidak ditemukan"})
		return
	}

	// 3. Cek apakah password yang diketik cocok dengan password acak (hash) di Supabase
	if !utils.CheckPasswordHash(input.Password, user.Password) {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Password salah"})
		return
	}

	// 4. Jika cocok, buatkan KTP Digital (Token JWT) yang berlaku selama 24 jam
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"user_id": user.ID,
		"role":    user.Role,
		"exp":     time.Now().Add(time.Hour * 24).Unix(),
	})

	tokenString, err := token.SignedString(jwtSecret)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membuat token"})
		return
	}

	// 5. Kirim pesan sukses dan Token-nya ke layar
	c.JSON(http.StatusOK, gin.H{
		"message": "Login berhasil!",
		"token":   tokenString,
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

	// 1. Cek apakah email terdaftar di Supabase
	var user models.User
	if err := config.DB.Where("email = ?", input.Email).First(&user).Error; err != nil {
		// Demi keamanan, jangan beri tahu kalau email tidak ada, bilang saja "Email dikirim"
		c.JSON(http.StatusOK, gin.H{"message": "Jika email terdaftar, OTP akan dikirimkan"})
		return
	}

	// 2. Generate OTP 6 Digit
	rand.Seed(time.Now().UnixNano())
	otp := fmt.Sprintf("%06d", rand.Intn(1000000))

	// 3. Simpan OTP dan Expiry (5 menit dari sekarang) ke DB
	expiry := time.Now().Add(5 * time.Minute)
	config.DB.Model(&user).Updates(models.User{
		ResetPasswordToken: otp,
		TokenExpiry:        &expiry,
	})

	// 4. Kirim Email via SMTP
	err := utils.SendOTPEmail(user.Email, otp)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengirim email"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Kode OTP telah dikirim ke email Anda"})
}

func ResetPassword(c *gin.Context) {
	// 1. Definisikan struktur input dari Flutter/Postman
	var input struct {
		Email       string `json:"email"`
		OTP         string `json:"otp"`
		NewPassword string `json:"new_password"`
	}

	// 2. Validasi format JSON
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Input tidak valid, pastikan email, otp, dan password baru terisi"})
		return
	}

	// 3. Cari user berdasarkan Email DAN Kode OTP yang cocok
	var user models.User
	err := config.DB.Where("email = ? AND reset_password_token = ?", input.Email, input.OTP).First(&user).Error

	if err != nil {
		// Jika kombinasi email & OTP tidak ditemukan
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Email atau kode OTP salah"})
		return
	}

	// 4. Cek apakah Kode OTP sudah kadaluarsa (Expiry check)
	// Kita gunakan "*" karena TokenExpiry di model adalah pointer (*time.Time)
	if user.TokenExpiry != nil && time.Now().After(*user.TokenExpiry) {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Kode OTP sudah kadaluarsa, silakan minta kode baru"})
		return
	}

	// 5. Hash Password Baru menggunakan Bcrypt
	// Jangan pernah simpan password dalam bentuk teks biasa!
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(input.NewPassword), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memproses password baru"})
		return
	}

	// 6. Update Database: Simpan password baru & Hapus jejak OTP
	// Kita set token & expiry ke NULL (nil) agar tidak bisa dipakai ulang
	err = config.DB.Model(&user).Updates(map[string]interface{}{
		"password":             string(hashedPassword),
		"reset_password_token": nil,
		"token_expiry":         nil,
	}).Error

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengupdate password di database"})
		return
	}

	// 7. Berikan respon sukses ke User
	c.JSON(http.StatusOK, gin.H{
		"message": "Password berhasil diperbarui! Silakan login menggunakan password baru Anda.",
	})
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

	// Cek Expiry juga
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
	// Cari user berdasarkan email. Jika tidak ketemu, buat user baru (FirstOrCreate)
	result := config.DB.Where("email = ?", input.Email).FirstOrCreate(&user, models.User{
		Name:      input.Name,
		Email:     input.Email,
		AvatarUrl: input.AvatarUrl,
		Role:      "customer", // Default role
	})

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal sinkronisasi data user"})
		return
	}

	// Kembalikan data user lengkap dengan ID aslinya dari database
	c.JSON(http.StatusOK, gin.H{
		"message": "Login berhasil",
		"user":    user,
	})
}
