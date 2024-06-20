package database

import (
	"database/sql"
	"errors"
	"mydiary-server/model"

	_ "github.com/go-sql-driver/mysql" // Import the MySQL driver
)

func CreateUser(name, email, password string) error {
	db, err := sql.Open("mysql", "root:@tcp(localhost:3306)/mydiary")
	if err != nil {
		return err
	}
	defer db.Close()

	// Prepare statement to insert user
	stmt, err := db.Prepare("INSERT INTO `user` (`name`, `email`, `password`) VALUES (?, ?, ?)")
	if err != nil {
		return err
	}
	defer stmt.Close()

	// Execute statement
	_, err = stmt.Exec(name, email, password)
	if err != nil {
		return err
	}

	return nil
}

func Login(email, password string) (model.User, error) {
	var user model.User

	// Connect to the database
	db, err := sql.Open("mysql", "root:@tcp(localhost:3306)/mydiary")
	if err != nil {
		return user, err
	}
	defer db.Close()

	// Query the database
	query := `SELECT id_user, name, email, password, create_at FROM user WHERE email = ? AND password = ?`
	err = db.QueryRow(query, email, password).Scan(&user.IDUser, &user.Name, &user.Email, &user.Password, &user.CreateAt)
	if err != nil {
		if err == sql.ErrNoRows {
			return user, errors.New("invalid credentials")
		}
		return user, err
	}

	return user, nil
}
