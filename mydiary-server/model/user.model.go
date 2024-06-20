package model

type User struct {
	IDUser   int    `json:"id_user"`
	Name     string `json:"name"`
	Email    string `json:"email"`
	Password string `json:"password"`
	CreateAt string `json:"create_at"`
}
