package main

// Simple static server of Angular compiled dist/project folder.
// A bit improved version.
import (
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"

	"webserv/common"
	"webserv/params"
	"webserv/treedata"
)

func main() {

	// Initialize database connection
	pgx := common.Pgx{}
	pgx.Init()

	// Init params then serve static folder
	args := params.OsArgs(os.Args)
	http.Handle("/", http.FileServer(http.Dir(args.StaticDir())))

	// Init treedata then serve its controllers & pass db connection
	tdata := treedata.TData(&pgx)
	http.HandleFunc("/api/postjsonstring", tdata.PostJsonData)
	http.HandleFunc("/api/gettreejsondata/", tdata.GetTreeJsonData)

	// Catch the Ctrl-C and SIGTERM from kill command
	ch := make(chan os.Signal, 1)
	signal.Notify(ch, os.Interrupt, os.Kill, syscall.SIGTERM)

	go func() {
		signalType := <-ch
		signal.Stop(ch)
		log.Println("Exit command received. Exiting...")
		log.Println("Terminate signal type: ", signalType)

		//*********************************************
		// Note: here call your app Close() method to
		// properly close resources before exiting.
		pgx.Con.Close()
		log.Println("Postgresql connection closed.")
		//*********************************************

		os.Exit(0)
	}()

	log.Printf("\nServing static folder: %s\nListening on port: %s\nPress Ctrl-C to stop server\n", args.StaticDir(), args.Port())

	if err := http.ListenAndServe(args.Port(), nil); err != nil {
		log.Fatal("Http server fatal panic error: ", err)
	}
}
