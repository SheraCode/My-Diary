package router

import (
	"mydiary-server/controller"

	"github.com/gin-gonic/gin"
)

func SetupRouter() *gin.Engine {
	r := gin.Default()
	userController := controller.NewUserController()
	diaryController := controller.NewDiaryController()

	r.POST("/users", userController.CreateUser)
	r.POST("/users/login", userController.Login)
	r.POST("/diary/create", diaryController.CreateDiary)
	r.GET("/diary/:user_id", diaryController.ViewAllDiary)
	r.GET("/diary/detail/:id_diary", diaryController.ViewAllDiaryBYID)
	r.PUT("/diary/update/:id", diaryController.UpdateDiary)
	r.DELETE("/diary/delete/:id_diary", diaryController.DeleteDiaryBYID)

	return r
}
