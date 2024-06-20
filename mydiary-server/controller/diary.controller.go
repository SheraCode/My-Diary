package controller

import (
	"mydiary-server/database"
	"mydiary-server/model"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

type DiaryController struct{}

func NewDiaryController() *DiaryController {
	return &DiaryController{}
}

func (uc *DiaryController) CreateDiary(c *gin.Context) {
	var user model.Diary
	if err := c.BindJSON(&user); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Call database function to create user
	err := database.CreateDiary(user.IDUser, user.Title, user.Diary)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "User created successfully!"})
}

func (sc *DiaryController) ViewAllDiary(c *gin.Context) {
	userIDParam := c.Param("user_id")
	if userIDParam == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing user_id parameter"})
		return
	}

	// Convert user_id parameter to integer
	userID, err := strconv.Atoi(userIDParam)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user_id parameter"})
		return
	}

	diaryALL, err := database.GetDiaryByUserID(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, diaryALL)
}

func (sc *DiaryController) ViewAllDiaryBYID(c *gin.Context) {
	diaryIDParam := c.Param("id_diary")
	if diaryIDParam == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing id_diary parameter"})
		return
	}

	// Convert id_diary parameter to integer
	diaryID, err := strconv.Atoi(diaryIDParam)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid id_diary parameter"})
		return
	}

	diaryALL, err := database.GetDiaryByID(diaryID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, diaryALL)
}

func (sc *DiaryController) UpdateDiary(c *gin.Context) {
	// Get diary ID from URL parameter
	IDDiary := c.Param("id")

	// Convert diary ID to int
	idDiary, err := strconv.Atoi(IDDiary)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID diary harus berupa bilangan bulat"})
		return
	}

	// Bind JSON request to Diary struct
	var request model.Diary
	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid data"})
		return
	}

	// Call database function to update diary entry based on ID
	err = database.UpdateDiary(idDiary, request.IDUser, request.Title, request.Diary)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Diary updated successfully"})
}

func (sc *DiaryController) DeleteDiaryBYID(c *gin.Context) {
	diaryIDParam := c.Param("id_diary")
	if diaryIDParam == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing id_diary parameter"})
		return
	}

	// Convert id_diary parameter to integer
	diaryID, err := strconv.Atoi(diaryIDParam)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid id_diary parameter"})
		return
	}

	diaryALL, err := database.DeleteDiaryByID(diaryID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, diaryALL)
}
