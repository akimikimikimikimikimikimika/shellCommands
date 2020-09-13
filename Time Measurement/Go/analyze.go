package main

import "os"
import "strings"

type analyzeKey int
const (
	akNone analyzeKey = iota
	akOut
	akErr
	akResult
	akMultiple
)

func argAnalyze(d *data) {
	l:=os.Args[1:]

	if len(l)==0 { error("引数が不足しています") } else {
		switch l[0] {
			case "-h","help","-help","--help":
				d.mode=cmHelp
			case "-v","version","-version","--version":
				d.mode=cmVersion
		}
	}

	key:=akNone
	for n,a := range l {
		if len(a)==0 { continue }

		proceed:=true
		switch a {
			case "-m","-multiple":
				d.multiple=mmSerial
				key=akMultiple
			case "-o","-out","-stdout": key=akOut
			case "-e","-err","-stderr": key=akErr
			case "-r","-result": key=akResult
			default: proceed=false
		}
		if proceed { continue }

		if strings.HasPrefix(a,"-") { error("不正なオプションが指定されています") } else
		if key!=akNone {
			proceed=true
			switch key {
				case akOut: d.out=a
				case akErr: d.err=a
				case akResult: d.result=a
				case akMultiple:
					switch a {
						case "none":
							d.multiple=mmNone
						case "serial","":
							d.multiple=mmSerial
						case "spawn","parallel":
							d.multiple=mmSpawn
						case "thread":
							d.multiple=mmThread
						default: proceed=false
					}
			}
			key=akNone
		}
		if proceed { continue }

		d.command=l[n:]
		break
	}

	if len(d.command)==0 { error("実行する内容が指定されていません") }
}