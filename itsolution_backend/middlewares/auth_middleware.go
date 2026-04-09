package middlewares

import (
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
)

// Pastikan kuncinya sama persis dengan yang ada di auth_controller.go
var jwtSecret = []byte("rahasia_skripsi_auron_123")

func RequireAuth(c *gin.Context) {
	// 1. Cek apakah ada surat izin (Header Authorization)
	authHeader := c.GetHeader("Authorization")
	if authHeader == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Akses ditolak! Token tidak ditemukan."})
		c.Abort() // Hentikan proses, jangan lanjut ke Controller
		return
	}

	// 2. Formatnya harus "Bearer <token_panjang_kamu>"
	parts := strings.Split(authHeader, " ")
	if len(parts) != 2 || parts[0] != "Bearer" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Format token salah! Gunakan format: Bearer <token>"})
		c.Abort()
		return
	}

	tokenString := parts[1]

	// 3. Cek keaslian Token menggunakan Kunci Rahasia
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		return jwtSecret, nil
	})

	if err != nil || !token.Valid {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Token palsu atau sudah kadaluarsa!"})
		c.Abort()
		return
	}

	// 4. Jika asli, ambil data "user_id" dari dalam token dan simpan ke memori sementara
	if claims, ok := token.Claims.(jwt.MapClaims); ok {
		c.Set("user_id", claims["user_id"])
		c.Set("role", claims["role"])
		c.Next() // Silakan masuk! Lanjut ke tujuan utama.
	} else {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Gagal membaca isi token"})
		c.Abort()
	}
}
