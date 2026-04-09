package utils

import "golang.org/x/crypto/bcrypt"

// Fungsi 1: Mengacak password saat user pertama kali Register
func HashPassword(password string) (string, error) {
	// Cost 14 adalah tingkat kerumitan acakan (semakin tinggi semakin aman, tapi sedikit lebih lambat)
	bytes, err := bcrypt.GenerateFromPassword([]byte(password), 14)
	return string(bytes), err
}

// Fungsi 2: Mengecek password saat user mau Login
func CheckPasswordHash(password string, hash string) bool {
	// Membandingkan teks asli yang diketik user dengan acakan yang ada di Supabase
	err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
	return err == nil // Jika nil (tidak ada error), berarti password cocok
}
