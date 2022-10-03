package common

import (
	"context"
	"fmt"
	"log"

	"github.com/jackc/pgx/v4/pgxpool"
)

// Postgresql connection for application-wide use
type Pgx struct {
	Ctx context.Context
	Con *pgxpool.Pool
}

// Postgresql connection parameters
var (
	user   = "postgres"
	pass   = "my-postgres-password"
	host   = "localhost"
	port   = "5432"
	dbname = "postgres"
	pgpath = fmt.Sprintf("postgres://%s:%s@%s:%s/%s",
		user, pass, host, port, dbname)
)

func (p *Pgx) Init() {
	var err error

	// Share the context for application-wide use
	p.Ctx = context.Background()

	// Open a database connection & share app-wide use
	p.Con, err = pgxpool.Connect(p.Ctx, pgpath)
	if err != nil {
		log.Fatal("Database connection error:", err.Error())
	}

	// Test query Postgresql for its version() function
	data := ""
	sql := `select version() "data"`
	if err = p.Con.QueryRow(p.Ctx, sql).Scan(&data); err != nil {
		log.Fatal("Database version query error:", err.Error())
	}
	log.Println(data)
}
