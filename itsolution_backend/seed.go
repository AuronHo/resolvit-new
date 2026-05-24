//go:build ignore

package main

import (
	"fmt"
	"itsolution-backend/config"
	"itsolution-backend/models"
	"time"

	"golang.org/x/crypto/bcrypt"
)

func hashPassword(pw string) string {
	b, _ := bcrypt.GenerateFromPassword([]byte(pw), bcrypt.DefaultCost)
	return string(b)
}

func main() {
	config.ConnectDatabase()
	db := config.DB

	// ── Users ──────────────────────────────────────────────────────────────────
	providers := []models.User{
		{Name: "admin", Email: "admin1@resolvit.com", Password: hashPassword("password123"), Role: "provider", Phone: "081234567890"},
		{Name: "admin", Email: "admin2@resolvit.com", Password: hashPassword("password123"), Role: "provider", Phone: "081234567891"},
		{Name: "admin", Email: "admin3@resolvit.com", Password: hashPassword("password123"), Role: "provider", Phone: "081234567892"},
		{Name: "admin", Email: "admin4@resolvit.com", Password: hashPassword("password123"), Role: "provider", Phone: "081234567893"},
		{Name: "admin", Email: "admin5@resolvit.com", Password: hashPassword("password123"), Role: "provider", Phone: "081234567894"},
	}
	customers := []models.User{
		{Name: "admin", Email: "admin6@resolvit.com", Password: hashPassword("password123"), Role: "provider", Phone: "082100000001"},
		{Name: "admin", Email: "admin7@resolvit.com", Password: hashPassword("password123"), Role: "provider", Phone: "082100000002"},
		{Name: "admin", Email: "admin8@resolvit.com", Password: hashPassword("password123"), Role: "provider", Phone: "082100000003"},
	}

	for i := range providers {
		db.Where("email = ?", providers[i].Email).FirstOrCreate(&providers[i])
	}
	for i := range customers {
		db.Where("email = ?", customers[i].Email).FirstOrCreate(&customers[i])
	}
	fmt.Println("✓ Users seeded")

	// ── Services ───────────────────────────────────────────────────────────────
	services := []models.Service{
		{
			ProviderID: int(providers[0].ID), Kategori: "Teknisi", NamaJasa: "Servis AC & Instalasi",
			DeskripsiJasa: "Servis, cuci, dan instalasi AC semua merek. Garansi 3 bulan.",
			HargaMulai: 150000, RatingRataRata: 4.8, JumlahProyekSelesai: 120,
			IsOpen: true, Location: "Jakarta Selatan", OperationalHours: "08:00 - 20:00",
			ImageUrl: "https://images.unsplash.com/photo-1585771724684-38269d6639fd?w=400",
		},
		{
			ProviderID: int(providers[0].ID), Kategori: "Teknisi", NamaJasa: "Perbaikan Kulkas & Mesin Cuci",
			DeskripsiJasa: "Teknisi berpengalaman 10 tahun. Spare part original.",
			HargaMulai: 100000, RatingRataRata: 4.6, JumlahProyekSelesai: 85,
			IsOpen: true, Location: "Jakarta Selatan", OperationalHours: "09:00 - 18:00",
			ImageUrl: "https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?w=400",
		},
		{
			ProviderID: int(providers[1].ID), Kategori: "Desain", NamaJasa: "Desain Logo & Branding",
			DeskripsiJasa: "Logo profesional untuk bisnis Anda. Revisi unlimited.",
			HargaMulai: 250000, RatingRataRata: 4.9, JumlahProyekSelesai: 200,
			IsOpen: true, Location: "Bandung", OperationalHours: "09:00 - 17:00",
			ImageUrl: "https://images.unsplash.com/photo-1626785774573-4b799315345d?w=400",
		},
		{
			ProviderID: int(providers[1].ID), Kategori: "Desain", NamaJasa: "Desain UI/UX Mobile App",
			DeskripsiJasa: "Figma prototype & handoff. Pengalaman 5 tahun di industri.",
			HargaMulai: 500000, RatingRataRata: 4.7, JumlahProyekSelesai: 60,
			IsOpen: true, Location: "Bandung", OperationalHours: "10:00 - 19:00",
			ImageUrl: "https://images.unsplash.com/photo-1559028012-481c04fa702d?w=400",
		},
		{
			ProviderID: int(providers[2].ID), Kategori: "Kebersihan", NamaJasa: "Cuci Sofa & Karpet",
			DeskripsiJasa: "Deep cleaning sofa, karpet, kasur. Bebas tungau & bakteri.",
			HargaMulai: 120000, RatingRataRata: 4.5, JumlahProyekSelesai: 310,
			IsOpen: true, Location: "Surabaya", OperationalHours: "08:00 - 17:00",
			ImageUrl: "https://images.unsplash.com/photo-1558317374-067fb5f30001?w=400",
		},
		{
			ProviderID: int(providers[2].ID), Kategori: "Kebersihan", NamaJasa: "General Cleaning Rumah",
			DeskripsiJasa: "Bersih-bersih menyeluruh termasuk dapur dan kamar mandi.",
			HargaMulai: 200000, RatingRataRata: 4.6, JumlahProyekSelesai: 150,
			IsOpen: true, Location: "Surabaya", OperationalHours: "07:00 - 16:00",
			ImageUrl: "https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=400",
		},
		{
			ProviderID: int(providers[3].ID), Kategori: "Pendidikan", NamaJasa: "Les Matematika & Fisika",
			DeskripsiJasa: "Bimbel online/offline SMP-SMA. Lulusan ITB.",
			HargaMulai: 80000, RatingRataRata: 4.9, JumlahProyekSelesai: 450,
			IsOpen: true, Location: "Yogyakarta", OperationalHours: "14:00 - 21:00",
			ImageUrl: "https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=400",
		},
		{
			ProviderID: int(providers[4].ID), Kategori: "Otomotif", NamaJasa: "Cuci Motor & Mobil",
			DeskripsiJasa: "Cuci steam + wax. Antar jemput area tertentu.",
			HargaMulai: 30000, RatingRataRata: 4.4, JumlahProyekSelesai: 800,
			IsOpen: true, Location: "Medan", OperationalHours: "08:00 - 20:00",
			ImageUrl: "https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?w=400",
		},
	}

	for i := range services {
		db.Where("\"NamaJasa\" = ? AND \"ProviderID\" = ?", services[i].NamaJasa, services[i].ProviderID).
			FirstOrCreate(&services[i])
	}
	fmt.Println("✓ Services seeded")

	// ── Reviews ────────────────────────────────────────────────────────────────
	reviewSets := []struct {
		jasaIdx int
		reviews []models.Review
	}{
		{0, []models.Review{
			{UserID: int(customers[0].ID), UserName: "admin", Rating: 5, Comment: "AC dingin banget, teknisi datang tepat waktu!"},
			{UserID: int(customers[1].ID), UserName: "admin", Rating: 5, Comment: "Sangat profesional, harga sesuai."},
			{UserID: int(customers[2].ID), UserName: "admin", Rating: 4, Comment: "Bagus, hanya perlu sedikit waktu lebih lama."},
		}},
		{2, []models.Review{
			{UserID: int(customers[0].ID), UserName: "admin", Rating: 5, Comment: "Logo hasilnya keren banget! Recommended!"},
			{UserID: int(customers[1].ID), UserName: "admin", Rating: 5, Comment: "Revisi cepat dan hasil memuaskan."},
		}},
		{6, []models.Review{
			{UserID: int(customers[2].ID), UserName: "admin", Rating: 5, Comment: "Nilai anak saya naik drastis. Guru sabar dan jelas."},
			{UserID: int(customers[0].ID), UserName: "admin", Rating: 5, Comment: "Metode ajarnya mudah dipahami."},
		}},
	}

	for _, rs := range reviewSets {
		svc := services[rs.jasaIdx]
		for _, rv := range rs.reviews {
			r := rv
			r.JasaID = int(svc.JasaID)
			r.CreatedAt = time.Now()
			db.Where("jasa_id = ? AND user_id = ?", r.JasaID, r.UserID).FirstOrCreate(&r)
		}
	}
	fmt.Println("✓ Reviews seeded")

	fmt.Println("\n✅ Seed selesai!")
}
