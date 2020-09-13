package main

import "fmt"
import "os"
import "regexp"

type commandMode int
const (
	cmMain commandMode = iota
	cmHelp
	cmVersion
)
type cm = commandMode

type multipleMode int
const (
	mmNone multipleMode = iota
	mmSerial
	mmSpawn
	mmThread
)
type mm = multipleMode

type data struct {
	mode cm
	command []string
	out string
	err string
	result string
	multiple mm
}

func initData() data {
	return data{
		mode:cmMain,
		command:[]string{},
		out:"inherit",
		err:"inherit",
		result:"stderr",
		multiple:mmNone,
	};
}

func error(text string) {
	fmt.Fprintln(os.Stderr,text)
	os.Exit(1)
}

func clean(text string) string {
	r1,_:=regexp.Compile(`(?m)^\t+`)
	r2,_:=regexp.Compile(`^\n`)
	text=r1.ReplaceAllString(text,"")
	text=r2.ReplaceAllString(text,"")
	return text
}