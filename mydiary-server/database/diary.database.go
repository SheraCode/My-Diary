package database

import (
	"database/sql"
	"mydiary-server/model"
)

func CreateDiary(iduser int, title, diary string) error {
	db, err := sql.Open("mysql", "root:@tcp(localhost:3306)/mydiary")
	if err != nil {
		return err
	}
	defer db.Close()

	// Prepare statement to insert user
	stmt, err := db.Prepare("INSERT INTO `diary` (`user_id`, `title`, `diary_user`) VALUES (?, ?, ?)")
	if err != nil {
		return err
	}
	defer stmt.Close()

	// Execute statement
	_, err = stmt.Exec(iduser, title, diary)
	if err != nil {
		return err
	}

	return nil
}

func GetDiaryByUserID(userID int) ([]model.Diary, error) {
	var viewAllDiary []model.Diary

	db, err := sql.Open("mysql", "root:@tcp(localhost:3306)/mydiary")
	if err != nil {
		return viewAllDiary, err
	}
	defer db.Close()

	query := "SELECT id_diary, user_id, title, diary_user, create_at, update_at FROM diary WHERE user_id = ?"
	rows, err := db.Query(query, userID)
	if err != nil {
		return viewAllDiary, err
	}
	defer rows.Close()

	for rows.Next() {
		var w model.Diary
		err := rows.Scan(&w.IDDiary, &w.IDUser, &w.Title, &w.Diary, &w.CreateAt, &w.UpdateAt)
		if err != nil {
			return viewAllDiary, err
		}

		viewAllDiary = append(viewAllDiary, w)
	}

	if err = rows.Err(); err != nil {
		return viewAllDiary, err
	}

	return viewAllDiary, nil
}

func GetDiaryByID(diaryID int) ([]model.Diary, error) {
	var viewAllDiary []model.Diary

	db, err := sql.Open("mysql", "root:@tcp(localhost:3306)/mydiary")
	if err != nil {
		return viewAllDiary, err
	}
	defer db.Close()

	query := "SELECT id_diary, user_id, title, diary_user, create_at, update_at FROM diary WHERE id_diary = ?"
	rows, err := db.Query(query, diaryID)
	if err != nil {
		return viewAllDiary, err
	}
	defer rows.Close()

	for rows.Next() {
		var w model.Diary
		err := rows.Scan(&w.IDDiary, &w.IDUser, &w.Title, &w.Diary, &w.CreateAt, &w.UpdateAt)
		if err != nil {
			return viewAllDiary, err
		}

		viewAllDiary = append(viewAllDiary, w)
	}

	if err = rows.Err(); err != nil {
		return viewAllDiary, err
	}

	return viewAllDiary, nil
}

func UpdateDiary(idDiary int, idUser int, title, diaryUser string) error {
	db, err := sql.Open("mysql", "root:@tcp(localhost:3306)/mydiary")
	if err != nil {
		return err
	}
	defer db.Close()

	// Prepare statement to update diary
	stmt, err := db.Prepare("UPDATE `diary` SET `title` = ?, `diary_user` = ? WHERE `id_diary` = ? AND `user_id` = ?")
	if err != nil {
		return err
	}
	defer stmt.Close()

	// Execute statement
	_, err = stmt.Exec(title, diaryUser, idDiary, idUser)
	if err != nil {
		return err
	}

	return nil
}

func DeleteDiaryByID(diaryID int) ([]model.Diary, error) {
	var viewAllDiary []model.Diary

	db, err := sql.Open("mysql", "root:@tcp(localhost:3306)/mydiary")
	if err != nil {
		return viewAllDiary, err
	}
	defer db.Close()

	query := "DELETE FROM diary WHERE id_diary = ?"
	rows, err := db.Query(query, diaryID)
	if err != nil {
		return viewAllDiary, err
	}
	defer rows.Close()

	return viewAllDiary, nil
}
