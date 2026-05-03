package controllers

import (
	"itsolution-backend/config"
	"itsolution-backend/models"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
)

func SearchServices(c *gin.Context) {
	query := strings.TrimSpace(c.Query("query"))
	userIDStr := c.Query("user_id")

	if query == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "query is required"})
		return
	}

	userID := 0
	if userIDStr != "" {
		parseUint(userIDStr, &userID)
	}

	like := "%" + query + "%"

	// Tier 1: exact ILIKE match
	var services []models.Service
	sql := `
		SELECT s.*,
		       CASE WHEN ss.id IS NOT NULL THEN true ELSE false END AS "IsBookmarked"
		FROM services s
		LEFT JOIN saved_services ss ON ss.jasa_id = s."JasaID" AND ss.user_id = ?
		WHERE s."NamaJasa" ILIKE ? OR s."DeskripsiJasa" ILIKE ?
		ORDER BY s."RatingRataRata" DESC
		LIMIT 20
	`
	config.DB.Raw(sql, userID, like, like).Scan(&services)

	if len(services) > 0 {
		c.JSON(http.StatusOK, gin.H{"results": services, "message": nil})
		return
	}

	// Tier 2: fuzzy trigram match (handles typos)
	var fuzzyServices []models.Service
	fuzzySql := `
		SELECT s.*,
		       CASE WHEN ss.id IS NOT NULL THEN true ELSE false END AS "IsBookmarked"
		FROM services s
		LEFT JOIN saved_services ss ON ss.jasa_id = s."JasaID" AND ss.user_id = ?
		WHERE similarity(s."NamaJasa", ?) > 0.15 OR similarity(s."DeskripsiJasa", ?) > 0.15
		ORDER BY
		    GREATEST(similarity(s."NamaJasa", ?), similarity(s."DeskripsiJasa", ?)) DESC,
		    s."RatingRataRata" DESC
		LIMIT 20
	`
	config.DB.Raw(fuzzySql, userID, query, query, query, query).Scan(&fuzzyServices)

	if len(fuzzyServices) > 0 {
		msg := "Tidak ditemukan hasil persis. Menampilkan hasil yang mirip dengan \"" + query + "\":"
		c.JSON(http.StatusOK, gin.H{"results": fuzzyServices, "message": msg})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"results": []interface{}{},
		"message": "Maaf, kami tidak menemukan layanan yang relevan untuk \"" + query + "\".",
	})
}

func parseUint(s string, out *int) {
	val := 0
	for _, ch := range s {
		if ch < '0' || ch > '9' {
			return
		}
		val = val*10 + int(ch-'0')
	}
	*out = val
}
