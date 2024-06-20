package model

type Diary struct {
	IDDiary  int    `json:"id_diary"`
	IDUser   int    `json:"user_id"`
	Title    string `json:"title"`
	Diary    string `json:"diary_user"`
	CreateAt string `json:"create_at"`
	UpdateAt string `json:"update_at"`
}
