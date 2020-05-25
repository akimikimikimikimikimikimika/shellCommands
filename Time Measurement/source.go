package main

import (
	"os"
	"os/exec"
	"fmt"
	"time"
	"math"
	"regexp"
)

func main() {
	var d = data()
	argAnalyze(&d)
	execute{}.exec(&d)
}

func argAnalyze(d *Data) {
	l := os.Args[1:]
	if len(l)==0 { error("引数が不足しています") } else {
		switch l[0] {
			case "-h","help","-help","--help": help()
			case "-v","version","-version","--version": version()
			default:
		}
	}
	var key AnalyzeKey = AKNone
	for n,a := range l {
		if key!=AKNone {
			switch key {
				case AKOut: d.out=a
				case AKErr: d.err=a
				case AKResult: d.result=a
			}
			key=AKNone
			continue
		}
		body:=false
		switch a {
			case "-o","-out","-stdout": key=AKOut
			case "-e","-err","-stderr": key=AKErr
			case "-r","-result": key=AKResult
			case "-m","-multiple": d.multiple=true
			default: body=true
		}
		if body {
			d.command=l[n:]
			break
		}
	}
	if len(d.command)==0 { error("実行する内容が指定されていません") }
}

type execute struct{
	data *Data
};
func (x execute) exec(d *Data) {
	x.data=d
	r:=d.result2f()
	ec:=0
	if d.multiple {
		l:=len(d.command)
		cl:=make([]*exec.Cmd,l)
		pl:=make([]int,l)
		for n,c:=range d.command {
			pl[n]=-1
			cl[n]=x.makeCmd(x.shell(c))
		}

		var pid int
		st:=time.Now()
		for n,c:=range cl {
			pid,ec=x.run(c)
			pl[n]=pid
			if ec!=0 { break }
		}
		en:=time.Now()
		fmt.Fprintln(r,fmt.Sprintf("time: %s",x.descTime(st,en)))
		for n,p:=range pl {
			pid:=fmt.Sprintf("%d",p)
			if p<0 { pid="N/A" }
			fmt.Fprintln(r,fmt.Sprintf("process%d id: %s",n+1,pid))
		}
		fmt.Fprintln(r,x.descEC(ec))
	} else {
		cmd:=x.makeCmd(d.command)
		var pid int
		st:=time.Now()
		pid,ec=x.run(cmd)
		en:=time.Now()
		fmt.Fprint(r,clean(fmt.Sprint(`
			time: `,x.descTime(st,en),`
			process id: `,pid,`
			`,x.descEC(ec),`
		`)))
	}
	if ec==-1 { os.Exit(255) } else { os.Exit(ec) }
}
func (x execute) shell(cmd string) []string{
	sh,has:=os.LookupEnv("SHELL")
	if !has {sh="sh"}
	return []string{sh,"-c",cmd}
}
func (x execute) makeCmd(args []string) *exec.Cmd {
	var cmd *exec.Cmd
	if len(args)==1 { cmd=exec.Command(args[0]) } else
	{ cmd=exec.Command(args[0],args[1:]...) }
	cmd.Stdin=os.Stdin
	o:=x.data.out2f()
	e:=x.data.err2f()
	if o!=nil { cmd.Stdout=o }
	if e!=nil { cmd.Stderr=e }
	return cmd
}
func (x execute) run(c *exec.Cmd) (int,int) {
	c.Run()
	s:=c.ProcessState
	if s==nil { error("実行に失敗しました") }
	return s.Pid(),s.ExitCode()
}
func (x execute) descTime(st time.Time,en time.Time) string {
	t:=""
	r:=float64(en.Sub(st))/(3600*1e+9)
	v:=math.Floor(r)
	if v>=1 { t+=fmt.Sprintf("%.0fh ",v) }
	r=(r-v)*60
	v=math.Floor(r)
	if v>=1 { t+=fmt.Sprintf("%.0fm ",v) }
	r=(r-v)*60
	v=math.Floor(r)
	if v>=1 { t+=fmt.Sprintf("%.0fs ",v) }
	r=(r-v)*1000
	t+=fmt.Sprintf("%07.3fms",r)
	return t
}
func (x execute) descEC(ec int) string {
	if ec==-1 { return "terminated due to signal" } else
	{ return fmt.Sprint("exit code: ",ec) }
}

func help() {
	fmt.Fprint(os.Stdout,clean(`

		 使い方:
		  measure [options] [command] [arg1] [arg2]…
		  measure -multiple [options] "[command1]" "[command2]"…

		  [command] を実行し,最後にその所要時間を表示します

		  オプション

		   -o,-out,-stdout
		   -e,-err,-stderr
		    標準出力,標準エラー出力の出力先を指定します
		    指定しなければ inherit になります
		    • inherit
		     stdoutはstdoutに,stderrはstderrにそれぞれ出力します
		    • discard
		     出力しません
		    • [file path]
		     指定したファイルに書き出します (追記)

		   -r,-result
		    実行結果の出力先を指定します
		    指定しなければ stderr になります
		    • stdout,stderr
		    • [file path]
		     指定したファイルに書き出します (追記)

		   -m,-multiple
		    複数のコマンドを実行します
		    通常はシェル経由で実行されます
		    例えば measure echo 1 と指定していたのを

		     measure -multiple "echo 1" "echo 2"

		    などと1つ1つのコマンドを1つの文字列として渡して実行します

	`))
	os.Exit(0)
}

func version() {
	fmt.Fprint(os.Stdout,clean(`

		 measure v2.2
		 Go バージョン (measure-go)

	`))
	os.Exit(0)
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



type AnalyzeKey int
const (
	AKNone AnalyzeKey = iota
	AKOut
	AKErr
	AKResult
)
type Data struct {
	command []string
	out string
	err string
	result string
	multiple bool
	opened map[string]*os.File
}
func data() Data {
	return Data{
		command:[]string{},
		out:"inherit",
		err:"inherit",
		result:"stderr",
		multiple:false,
		opened:map[string]*os.File{},
	};
}
func (d Data) out2f() *os.File {
	switch d.out {
		case "inherit": return os.Stdout
		case "discard": return nil
		default: return d.fh(d.out)
	}
}
func (d Data) err2f() *os.File {
	switch d.err {
		case "inherit": return os.Stderr
		case "discard": return nil
		default: return d.fh(d.err)
	}
}
func (d Data) result2f() *os.File {
	switch d.result {
		case "stdout": return os.Stdout
		case "stderr": return os.Stderr
		default: return d.fh(d.result)
	}
}
func (d Data) fh(path string) *os.File {
	ef,has := d.opened[path]
	if has { return ef }
	f,e := os.OpenFile(path,os.O_APPEND|os.O_CREATE|os.O_WRONLY,0644)
	if e != nil { error("指定したパスには書き込みできません: "+path) }
	d.opened[path]=f
	return f
}