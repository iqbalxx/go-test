package main

import (
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"os"

	//_ "://github.com" 
)

func main() {
	// Connect to PostgreSQL using the DATABASE_URL environment variable
	db, err := sql.Open("pgx", os.Getenv("DATABASE_URL"))
	if err != nil {
		log.Fatalf("Failed to open database connection: %v", err)
	}
	defer db.Close()

	// GET /healthz - Always returns 200 OK when the process is running
	http.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
			return
		}
		w.WriteHeader(http.StatusOK)
		fmt.Fprint(w, "OK")
	})

	// GET /readyz - Returns 200 OK only if Postgres is reachable
	http.HandleFunc("/readyz", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
			return
		}

		// Ping the database to verify the connection is alive
		if err := db.Ping(); err != nil {
			log.Printf("Readyz probe failed: %v", err)
			http.Error(w, "Service Unavailable", http.StatusServiceUnavailable)
			return
		}

		w.WriteHeader(http.StatusOK)
		fmt.Fprint(w, "OK")
	})

	log.Println("Starting service on :8080...")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatalf("Server failed: %v", err)
	}
}
