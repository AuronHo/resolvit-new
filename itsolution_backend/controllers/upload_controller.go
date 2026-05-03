package controllers

import (
	"bytes"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
)

func UploadAvatar(c *gin.Context) {
	file, header, err := c.Request.FormFile("avatar")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "avatar file is required"})
		return
	}
	defer file.Close()

	ext := strings.ToLower(filepath.Ext(header.Filename))
	if ext != ".jpg" && ext != ".jpeg" && ext != ".png" && ext != ".webp" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Only jpg, jpeg, png, webp allowed"})
		return
	}

	fileBytes, err := io.ReadAll(file)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to read file"})
		return
	}

	supabaseURL := os.Getenv("SUPABASE_URL")
	serviceKey := os.Getenv("SUPABASE_SERVICE_KEY")

	if supabaseURL == "" || serviceKey == "" {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Storage not configured"})
		return
	}

	contentType := "image/jpeg"
	if ext == ".png" {
		contentType = "image/png"
	} else if ext == ".webp" {
		contentType = "image/webp"
	}

	filename := fmt.Sprintf("avatar_%d%s", time.Now().UnixNano(), ext)
	uploadURL := fmt.Sprintf("%s/storage/v1/object/avatars/%s", supabaseURL, filename)

	req, err := http.NewRequest("POST", uploadURL, bytes.NewReader(fileBytes))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create upload request"})
		return
	}
	req.Header.Set("Authorization", "Bearer "+serviceKey)
	req.Header.Set("Content-Type", contentType)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Upload request failed: " + err.Error()})
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 300 {
		body, _ := io.ReadAll(resp.Body)
		errMsg := fmt.Sprintf("Supabase storage error %d: %s", resp.StatusCode, string(body))
		fmt.Println("[UploadAvatar]", errMsg)
		c.JSON(http.StatusInternalServerError, gin.H{"error": errMsg})
		return
	}

	publicURL := fmt.Sprintf("%s/storage/v1/object/public/avatars/%s", supabaseURL, filename)
	c.JSON(http.StatusOK, gin.H{"url": publicURL})
}
