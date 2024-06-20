package main

import (
	"log"
	"mydiary-server/router"
	"net/http"
)

func main() {
	Auth := router.SetupRouter()
	log.Fatal(http.ListenAndServe(":2005", Auth))
}
