package controllers

import (
	"itsolution-backend/config"
	"itsolution-backend/models"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

// Change this to your actual config import path
// Change this to your actual models import path

// GetRecommendations fetches top-rated services for the Home Screen
func GetRecommendations(c *gin.Context) {
	userID := c.Query("user_id")
	if userID == "" {
		userID = "0"
	}

	sql := `
		SELECT
			s."JasaID", s."ProviderID", s."Kategori", s."NamaJasa", s."DeskripsiJasa",
			s."HargaMulai", s."RatingRataRata", s."JumlahProyekSelesai",
			s.is_open, s.location, s.operational_hours, s.created_at,
			COALESCE(NULLIF(s.image_url, ''), u.avatar_url, '') AS image_url,
			CASE WHEN ss.id IS NOT NULL THEN true ELSE false END AS "IsBookmarked"
		FROM services s
		LEFT JOIN saved_services ss ON s."JasaID" = ss.jasa_id AND ss.user_id = ?
		LEFT JOIN users u ON u.id = s."ProviderID"
		ORDER BY s."RatingRataRata" DESC
		LIMIT 5
	`
	var services []models.Service
	if err := config.DB.Raw(sql, userID).Scan(&services).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch recommendations"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Recommendations fetched successfully",
		"results": services,
	})
}

func GetServiceByID(c *gin.Context) {
	id := c.Param("id")
	sql := `
		SELECT
			s."JasaID", s."ProviderID", s."Kategori", s."NamaJasa", s."DeskripsiJasa",
			s."HargaMulai", s."RatingRataRata", s."JumlahProyekSelesai",
			s.is_open, s.location, s.operational_hours, s.created_at,
			COALESCE(NULLIF(s.image_url, ''), u.avatar_url, '') AS image_url
		FROM services s
		LEFT JOIN users u ON u.id = s."ProviderID"
		WHERE s."JasaID" = ?
	`
	var service models.Service
	if err := config.DB.Raw(sql, id).Scan(&service).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch service"})
		return
	}
	if service.JasaID == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Service not found"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"service": service})
}

func GetMyService(c *gin.Context) {
	userIDStr := c.Query("user_id")
	userID, err := strconv.Atoi(userIDStr)
	if err != nil || userID == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "user_id required"})
		return
	}
	var service models.Service
	if err := config.DB.Where(`"ProviderID" = ?`, userID).Order(`"JasaID" DESC`).First(&service).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "No service found"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"service": service})
}

func UpdateService(c *gin.Context) {
	id := c.Param("id")
	var input struct {
		NamaJasa         string `json:"NamaJasa"`
		Kategori         string `json:"Kategori"`
		DeskripsiJasa    string `json:"DeskripsiJasa"`
		HargaMulai       int64  `json:"HargaMulai"`
		Location         string `json:"location"`
		OperationalHours string `json:"operational_hours"`
	}
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid input"})
		return
	}
	updates := map[string]interface{}{}
	if input.NamaJasa != "" {
		updates["NamaJasa"] = input.NamaJasa
	}
	if input.Kategori != "" {
		updates["Kategori"] = input.Kategori
	}
	if input.DeskripsiJasa != "" {
		updates["DeskripsiJasa"] = input.DeskripsiJasa
	}
	if input.HargaMulai > 0 {
		updates["HargaMulai"] = input.HargaMulai
	}
	if input.Location != "" {
		updates["location"] = input.Location
	}
	if input.OperationalHours != "" {
		updates["operational_hours"] = input.OperationalHours
	}
	if err := config.DB.Model(&models.Service{}).Where(`"JasaID" = ?`, id).Updates(updates).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update service"})
		return
	}
	var service models.Service
	config.DB.Where(`"JasaID" = ?`, id).First(&service)
	c.JSON(http.StatusOK, gin.H{"message": "Service updated", "service": service})
}

func CreateService(c *gin.Context) {
	var input struct {
		ProviderID       int    `json:"provider_id"`
		NamaJasa         string `json:"NamaJasa"`
		Kategori         string `json:"Kategori"`
		DeskripsiJasa    string `json:"DeskripsiJasa"`
		HargaMulai       int64  `json:"HargaMulai"`
		Location         string `json:"location"`
		OperationalHours string `json:"operational_hours"`
	}
	if err := c.ShouldBindJSON(&input); err != nil || input.ProviderID == 0 || input.NamaJasa == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "provider_id and NamaJasa are required"})
		return
	}

	// Upsert: update if provider already has a service, create otherwise
	var existing models.Service
	if config.DB.Where(`"ProviderID" = ?`, input.ProviderID).Order(`"JasaID" DESC`).First(&existing).Error == nil {
		updates := map[string]interface{}{
			"NamaJasa":         input.NamaJasa,
			"Kategori":         input.Kategori,
			"DeskripsiJasa":    input.DeskripsiJasa,
			"HargaMulai":       input.HargaMulai,
			"location":         input.Location,
			"operational_hours": input.OperationalHours,
			"is_open":          true,
		}
		config.DB.Model(&existing).Updates(updates)
		c.JSON(http.StatusOK, gin.H{"message": "Service updated", "service": existing})
		return
	}

	service := models.Service{
		ProviderID:       input.ProviderID,
		NamaJasa:         input.NamaJasa,
		Kategori:         input.Kategori,
		DeskripsiJasa:    input.DeskripsiJasa,
		HargaMulai:       input.HargaMulai,
		Location:         input.Location,
		OperationalHours: input.OperationalHours,
		IsOpen:           true,
	}
	if err := config.DB.Create(&service).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create service"})
		return
	}
	c.JSON(http.StatusCreated, gin.H{"message": "Service created", "service": service})
}

func GetServicesByCategory(c *gin.Context) {
	categoryName := c.Query("name")
	pageStr := c.DefaultQuery("page", "1")
	page, _ := strconv.Atoi(pageStr)
	limit := 10
	offset := (page - 1) * limit

	userID := c.Query("user_id")
	if userID == "" {
		userID = "0"
	}

	var services []models.Service
	var err error

	if categoryName == "" || categoryName == "all" {
		sql := `
			SELECT
				s."JasaID", s."ProviderID", s."Kategori", s."NamaJasa", s."DeskripsiJasa",
				s."HargaMulai", s."RatingRataRata", s."JumlahProyekSelesai",
				s.is_open, s.location, s.operational_hours, s.created_at,
				COALESCE(NULLIF(s.image_url, ''), u.avatar_url, '') AS image_url,
				CASE WHEN ss.id IS NOT NULL THEN true ELSE false END AS "IsBookmarked"
			FROM services s
			LEFT JOIN saved_services ss ON s."JasaID" = ss.jasa_id AND ss.user_id = ?
			LEFT JOIN users u ON u.id = s."ProviderID"
			ORDER BY s."RatingRataRata" DESC
			LIMIT ? OFFSET ?
		`
		err = config.DB.Raw(sql, userID, limit, offset).Scan(&services).Error
	} else {
		sql := `
			SELECT
				s."JasaID", s."ProviderID", s."Kategori", s."NamaJasa", s."DeskripsiJasa",
				s."HargaMulai", s."RatingRataRata", s."JumlahProyekSelesai",
				s.is_open, s.location, s.operational_hours, s.created_at,
				COALESCE(NULLIF(s.image_url, ''), u.avatar_url, '') AS image_url,
				CASE WHEN ss.id IS NOT NULL THEN true ELSE false END AS "IsBookmarked"
			FROM services s
			LEFT JOIN saved_services ss ON s."JasaID" = ss.jasa_id AND ss.user_id = ?
			LEFT JOIN users u ON u.id = s."ProviderID"
			WHERE s."Kategori" = ?
			LIMIT ? OFFSET ?
		`
		err = config.DB.Raw(sql, userID, categoryName, limit, offset).Scan(&services).Error
	}

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch services"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Services fetched successfully",
		"results": services,
	})
}
