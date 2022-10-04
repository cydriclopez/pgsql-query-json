package treedata

import (
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"net/http"

	"webserv/common"

	"github.com/jackc/pgconn"
)

// ***********************************************************
// This JsonData should agree with Angular-side interface
type JsonData struct {
	Data string `json:"data"`
} // *********************************************************
// Angular-side interface in src/app/services/nodeservice.ts
// export interface JsonData {
//     data:   string;
// }
// ***********************************************************

// Small-case non-exported local identifier
type tData struct {
	Jdata JsonData
	Pgx   *common.Pgx
}

// Constructor pattern using factory method
func TData(pgx *common.Pgx) *tData {
	t := new(tData)
	t.Pgx = pgx
	return t
}

// Controller for url "/api/postjsonstring"
func (t *tData) PostJsonData(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodPost {

		var err error
		var unmarshalTypeError *json.UnmarshalTypeError

		// Scan then parse json data
		decoder := json.NewDecoder(r.Body)
		if err = decoder.Decode(&t.Jdata); err != nil {

			if errors.As(err, &unmarshalTypeError) {
				jsonResponse(w, http.StatusBadRequest, "Error wrong data type: "+unmarshalTypeError.Field)
			} else {
				jsonResponse(w, http.StatusBadRequest, "Error: "+err.Error())
			}

			return
		}

		// Save json data to db
		if err = t.saveJsonData(); err != nil {

			var pgErr *pgconn.PgError
			var errmsg string

			if errors.As(err, &pgErr) {
				errmsg = fmt.Sprintf("Postgresql error: (%s) %s", pgErr.Code, pgErr.Message)
			} else {
				errmsg = "Error: " + err.Error()
			}

			log.Print(errmsg)
			jsonResponse(w, http.StatusInternalServerError, errmsg)
			return
		}

		jsonResponse(w, http.StatusOK, "Success")
		return
	}

	log.Print("http.NotFound")
	http.NotFound(w, r)
}

// Save json data to db
func (t *tData) saveJsonData() error {
	// Print the data from the client
	log.Println("jsonData:", t.Jdata.Data)

	// SQL statement to call the stored-function
	sql := "select tree_insert($1)"

	// Call the Postgresql stored-function
	if _, err := t.Pgx.Con.Exec(t.Pgx.Ctx, sql, t.Jdata.Data); err != nil {
		return err
	}
	return nil
}

// Controller for url "/api/gettreejsondata"
func (t *tData) GetTreeJsonData(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodGet {

		var pgErr *pgconn.PgError
		var errmsg string
		var err error
		var data []byte

		w.Header().Set("Content-Type", "application/json")

		if data, err = t.getTreeJsonData(); err != nil {
			if errors.As(err, &pgErr) {
				errmsg = fmt.Sprintf("Postgresql error: (%s) %s", pgErr.Code, pgErr.Message)
			} else {
				errmsg = "Error: " + err.Error()
			}

			log.Print(errmsg)
			jsonResponse(w, http.StatusInternalServerError, errmsg)
			return
		}

		w.Write(data)
		return
	}

	http.NotFound(w, r)
}

func (t *tData) getTreeJsonData() ([]byte, error) {
	var data []byte

	// Result alias "data" needed for Scan(&data) to work
	sql := `select tree_json() "data";`

	// Call Postgresql stored-function tree_json() to
	// get the tree component JSON data.
	if err := t.Pgx.Con.QueryRow(t.Pgx.Ctx, sql).Scan(&data); err != nil {
		return nil, err
	}

	return data, nil
}

func jsonResponse(w http.ResponseWriter, statusCode int, errorMsg string) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(statusCode)

	// For production, use generic "Bad request or data error".
	// Detailed error message is not advised in production.
	w.Write([]byte(fmt.Sprintf(`{"message": "%s"}`, errorMsg) + "\n"))
}
