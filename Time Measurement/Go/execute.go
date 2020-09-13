package main

import "fmt"
import "os"
import "os/exec"
import "time"
import "sync"
import "math"

type execute struct{
	d *data
	o *os.File
	e *os.File
	r *os.File
	res string
	ec int
	opened map[string]*os.File
};



func ex(d *data) {
	x:=execute{
		d:d,
		ec:0,
		opened:map[string]*os.File{},
	}
	x.o=x.co2f(d.out,os.Stdout)
	x.e=x.co2f(d.err,os.Stderr)
	x.r=x.ro2f(d.result)

	switch d.multiple {
		case mmNone:   x.single()
		case mmSerial: x.serial()
		case mmSpawn:  x.spawn()
		case mmThread: x.thread()
	}

	fmt.Fprint(x.r,x.res)
	x.o.Close()
	x.e.Close()
	x.r.Close()

	if x.ec==-1 { os.Exit(1) } else { os.Exit(x.ec) }
}

func (x *execute) single() {
	p:=x.sp(x.d.command)

	st:=time.Now()
	p.run()
	en:=time.Now()

	x.res=clean(fmt.Sprint(`
		time: `,x.descTime(st,en),`
		process id: `,p.pid,`
		`,p.descEC(),`
	`))
	x.ec=p.ec
}

func (x *execute) serial() {
	pl:=x.spMultiple(x.d.command)
	var lp *sp=pl[len(pl)-1]

	st:=time.Now()
	for _,p:=range pl {
		p.run()
		if p.ec!=0 {
			lp=p
			break
		}
	}
	en:=time.Now()

	x.res=fmt.Sprintf("time: %s\n",x.descTime(st,en))
	for _,p:=range pl {
		pid:=fmt.Sprintf("%d",p.pid)
		if p.pid<0 { pid="N/A" }
		x.res+=fmt.Sprintf("process%d id: %s\n",p.order,pid)
	}
	x.res+=lp.descEC()+"\n"

	x.ec=lp.ec
}

func (x *execute) spawn() {
	pl:=x.spMultiple(x.d.command)

	st:=time.Now()
	for _,p:=range pl { p.start() }
	for _,p:=range pl { p.wait() }
	en:=time.Now()

	x.collect(pl,st,en)
}

func (x *execute) thread() {
	pl:=x.spMultiple(x.d.command)
	wg:=&sync.WaitGroup{}

	st:=time.Now()
	for _,p:=range pl {
		wg.Add(1)
		go x.threadFunc(p,wg)
	}
	wg.Wait()
	en:=time.Now()

	x.collect(pl,st,en)
}

func (x *execute) threadFunc(p *sp,wg *sync.WaitGroup) {
	p.run()
	wg.Done()
}

type sp struct {
	cmd *exec.Cmd
	parent *execute
	order int
	pid int
	ec int
}
func (x *execute) sp(args []string) *sp {

	var cmd *exec.Cmd
	if len(args)==1 { cmd=exec.Command(args[0]) } else
	{ cmd=exec.Command(args[0],args[1:]...) }
	cmd.Stdin=os.Stdin
	if x.o!=nil { cmd.Stdout=x.o }
	if x.e!=nil { cmd.Stderr=x.e }

	return &sp{
		cmd:cmd,
		parent:x,
		order:0,
		pid:-1,
		ec:0,
	}
}
func (x *execute) spMultiple(commands []string) []*sp {
	sh,has:=os.LookupEnv("SHELL")
	if !has {sh="sh"}
	l:=make([]*sp,len(commands))
	for n,c:=range commands {
		var p=x.sp([]string{sh,"-c",c})
		p.order=n+1
		l[n]=p
	}
	return l
}
func (x *execute) collect(pl []*sp,st time.Time,en time.Time) {
	x.res=fmt.Sprintf("time: %s\n",x.descTime(st,en))
	for _,p:=range pl {
		x.res+=fmt.Sprintf("process%d id: %d\n",p.order,p.pid)
		x.res+=p.descEC()+"\n"
		if p.ec>x.ec { x.ec=p.ec }
	}
}

func (p *sp) start() {
	e:=p.cmd.Start()
	if e!=nil { error("起動に失敗しました") }
	p.pid=p.cmd.Process.Pid
}
func (p *sp) wait() {
	p.cmd.Wait()
	p.ec=p.cmd.ProcessState.ExitCode()
}
func (p *sp) run() {
	p.start()
	p.wait()
}
func (p *sp) descEC() string {
	var s string
	if p.ec==-1 { s="terminated due to signal" } else
	{ s=fmt.Sprint("exit code: ",p.ec) }
	return s
}



func (x *execute) co2f(d string,inherit *os.File) *os.File {
	switch d {
		case "inherit": return inherit
		case "discard": return nil
		default: return nil
	}
}
func (x *execute) ro2f(d string) *os.File {
	switch d {
		case "stdout": return os.Stdout
		case "stderr": return os.Stderr
		default: return x.fh(d)
	}
}
func (x *execute) fh(path string) *os.File {
	ef,has := x.opened[path]
	if has { return ef }
	f,e := os.OpenFile(path,os.O_APPEND|os.O_CREATE|os.O_WRONLY,0644)
	if e != nil { error("指定したパスには書き込みできません: "+path) }
	x.opened[path]=f
	return f
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