package controllers

import (
	"encoding/json"
	"itsolution-backend/config"
	"itsolution-backend/models"
	"net/http"
	"strconv"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
)

var wsUpgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool { return true },
}

type wsClient struct {
	conn   *websocket.Conn
	userID int
}

var (
	chatRooms   = make(map[int]map[*wsClient]bool)
	chatRoomsMu sync.RWMutex
)

func registerClient(roomID int, client *wsClient) {
	chatRoomsMu.Lock()
	defer chatRoomsMu.Unlock()
	if chatRooms[roomID] == nil {
		chatRooms[roomID] = make(map[*wsClient]bool)
	}
	chatRooms[roomID][client] = true
}

func unregisterClient(roomID int, client *wsClient) {
	chatRoomsMu.Lock()
	defer chatRoomsMu.Unlock()
	delete(chatRooms[roomID], client)
}

func broadcastToRoom(roomID int, data []byte) {
	chatRoomsMu.RLock()
	defer chatRoomsMu.RUnlock()
	for client := range chatRooms[roomID] {
		client.conn.WriteMessage(websocket.TextMessage, data)
	}
}

// GET /ws/chat/:room_id?user_id=:id
func ChatWebSocket(c *gin.Context) {
	roomIDStr := c.Param("room_id")
	roomID, err := strconv.Atoi(roomIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid room ID"})
		return
	}

	userIDStr := c.Query("user_id")
	userID, _ := strconv.Atoi(userIDStr)

	conn, err := wsUpgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		return
	}

	client := &wsClient{conn: conn, userID: userID}
	registerClient(roomID, client)
	defer func() {
		unregisterClient(roomID, client)
		conn.Close()
	}()

	for {
		_, msgBytes, err := conn.ReadMessage()
		if err != nil {
			break
		}

		var input struct {
			Content string `json:"content"`
		}
		if err := json.Unmarshal(msgBytes, &input); err != nil || input.Content == "" {
			continue
		}

		msg := models.ChatMessage{
			RoomID:    roomID,
			SenderID:  userID,
			Content:   input.Content,
			CreatedAt: time.Now(),
		}
		config.DB.Create(&msg)

		config.DB.Model(&models.ChatRoom{}).
			Where("id = ?", roomID).
			Updates(map[string]interface{}{"last_message": input.Content, "updated_at": time.Now()})

		outBytes, _ := json.Marshal(msg)
		broadcastToRoom(roomID, outBytes)
	}
}

// POST /api/chats — create or get existing chat room
func GetOrCreateChatRoom(c *gin.Context) {
	var input struct {
		CustomerID int    `json:"customer_id"`
		ProviderID int    `json:"provider_id"`
		JasaID     int    `json:"jasa_id"`
		JasaName   string `json:"jasa_name"`
	}
	if err := c.ShouldBindJSON(&input); err != nil || input.CustomerID == 0 || input.ProviderID == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "customer_id and provider_id are required"})
		return
	}

	var room models.ChatRoom
	result := config.DB.Where("customer_id = ? AND provider_id = ? AND jasa_id = ?",
		input.CustomerID, input.ProviderID, input.JasaID).First(&room)

	if result.Error != nil {
		room = models.ChatRoom{
			CustomerID: input.CustomerID,
			ProviderID: input.ProviderID,
			JasaID:     input.JasaID,
			JasaName:   input.JasaName,
		}
		config.DB.Create(&room)
	}

	c.JSON(http.StatusOK, gin.H{"room": room})
}

// GET /api/chats?user_id=:id — list rooms for a user
func GetChatRooms(c *gin.Context) {
	userIDStr := c.Query("user_id")
	userID, err := strconv.Atoi(userIDStr)
	if err != nil || userID == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "user_id is required"})
		return
	}

	var rooms []models.ChatRoom
	config.DB.Where("customer_id = ? OR provider_id = ?", userID, userID).
		Order("updated_at DESC").
		Find(&rooms)

	// Attach partner info for display
	type RoomWithPartner struct {
		models.ChatRoom
		PartnerName   string `json:"partner_name"`
		PartnerAvatar string `json:"partner_avatar"`
	}

	result := make([]RoomWithPartner, 0, len(rooms))
	for _, r := range rooms {
		partnerID := r.ProviderID
		if r.CustomerID != userID {
			partnerID = r.CustomerID
		}
		var partner models.User
		config.DB.First(&partner, partnerID)
		partnerName := partner.Name
		if partnerName == "" {
			partnerName = r.JasaName
		}
		result = append(result, RoomWithPartner{
			ChatRoom:      r,
			PartnerName:   partnerName,
			PartnerAvatar: partner.AvatarUrl,
		})
	}

	c.JSON(http.StatusOK, gin.H{"results": result})
}

// GET /api/chats/:room_id/messages — message history
func GetChatMessages(c *gin.Context) {
	roomIDStr := c.Param("room_id")
	roomID, err := strconv.Atoi(roomIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid room ID"})
		return
	}

	var messages []models.ChatMessage
	config.DB.Where("room_id = ?", roomID).
		Order("created_at ASC").
		Find(&messages)

	c.JSON(http.StatusOK, gin.H{"results": messages})
}
