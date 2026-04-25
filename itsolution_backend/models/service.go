package models

import "time"

type Service struct {
	// Ganti ID menjadi JasaID agar sesuai dengan CSV dan Flutter
	JasaID              uint    `gorm:"column:JasaID;primaryKey" json:"JasaID"`
	ProviderID          int     `gorm:"column:ProviderID" json:"ProviderID"`
	Kategori            string  `gorm:"column:Kategori" json:"Kategori"`
	NamaJasa            string  `gorm:"column:NamaJasa" json:"NamaJasa"`
	DeskripsiJasa       string  `gorm:"column:DeskripsiJasa" json:"DeskripsiJasa"`
	HargaMulai          int64   `gorm:"column:HargaMulai" json:"HargaMulai"`
	RatingRataRata      float64 `gorm:"column:RatingRataRata" json:"RatingRataRata"`
	JumlahProyekSelesai int     `gorm:"column:JumlahProyekSelesai" json:"JumlahProyekSelesai"`

	// Tiga kolom ini tetap snake_case karena digenerate otomatis oleh database/kita
	IsOpen    bool      `gorm:"column:is_open" json:"IsOpen"`
	ImageUrl  string    `gorm:"column:image_url" json:"ImageUrl"`
	CreatedAt time.Time `gorm:"column:created_at" json:"CreatedAt"`

	IsBookmarked bool `gorm:"column:IsBookmarked;->" json:"IsBookmarked"`
}

func (Service) TableName() string {
	return "services"
}
