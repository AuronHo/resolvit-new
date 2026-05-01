package config

import (
	"fmt"
	"os"

	"github.com/joho/godotenv"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DB *gorm.DB

func ConnectDatabase() {
	// 1. Coba load .env dari root folder
	err := godotenv.Load()
	if err != nil {
		fmt.Println("Peringatan: Tidak bisa memuat file .env, menggunakan sistem OS env")
	}

	// 2. Ambil URL
	dsn := os.Getenv("DB_URL")

	// DEBUG: Cetak DSN untuk memastikan isinya tidak kosong (Hapus jika sudah berhasil)
	fmt.Println("Menghubungkan ke:", dsn)

	if dsn == "" {
		panic("ERROR: DB_URL kosong! Cek file .env kamu.")
	}

	database, err := gorm.Open(postgres.New(postgres.Config{
		DSN:                  dsn,
		PreferSimpleProtocol: true, // MATIKAN PREPARED STATEMENT DI TINGKAT PROTOKOL
	}), &gorm.Config{
		PrepareStmt: false,
	})

	if err != nil {
		panic("Gagal koneksi ke database: " + err.Error())
	}

	DB = database
	fmt.Println("Koneksi Database Berhasil!")
}
