package params

import (
	"log"
	"os"
)

// Small-case non-exported local identifier
type osArgs struct {
	Args   []string
	Folder string
	PortNo string // `default:"3000"`
	Config string
}

var noParamsMsg = `
Simple static server of Angular compiled dist/project folder.
Run "ng build --watch" then in another terminal
use dist/project folder as parameter for this utility.
Usage:
%[1]v STATIC_FOLDER_TO_SERVE [PORT]
Default port: 3000
Examples:
%[1]v .
%[1]v ~/Projects/ng/ultima12/dist/ultima
%[1]v ~/Projects/ng/ultima12/dist/ultima 4000
`

// Constructor pattern using factory method
func OsArgs(args []string) *osArgs {
	o := new(osArgs)
	o.Args = args
	o.Folder = ""
	o.PortNo = "3000" // default

	paramCount := len(args)

	if paramCount == 1 {
		// Nothing to do no folder & port are given
		log.Fatalf(noParamsMsg, args[0])

	} else if paramCount > 2 {
		// Folder & port are given so use them
		o.Folder = args[1]
		o.PortNo = args[2]

	} else {
		// Only folder is given use default port
		o.Folder = args[1]
	}

	if _, err := os.Stat(o.Folder); os.IsNotExist(err) {
		log.Fatal("Folder does not exist.")
		return nil
	} else {
		return o // Ok, return instance of osArgs
	}
}

func (o *osArgs) StaticDir() string {
	return o.Folder
}

func (o *osArgs) Port() string {
	return ":" + o.PortNo
}
