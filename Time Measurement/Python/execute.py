from math import floor
import datetime
now=datetime.datetime.now
import os
from os import linesep
from sys import stdout,stderr
import subprocess
import threading
from lib import MM,data,error,clean

d=None
o=None
e=None
r=None

res=""
ec=0

def execute(rd:data):
	global d,o,e,r
	d=rd
	o=co2f(d.out)
	e=co2f(d.err)
	r=ro2f(d.result)

	if d.multiple==MM.none: single()
	if d.multiple==MM.serial: serial()
	if d.multiple==MM.spawn: spawn()
	if d.multiple==MM.thread: thread()

	r.write(res)
	close(o)
	close(e)
	close(r)
	exit(ec)

def single():
	global res,ec
	p=SP(d.command)

	st=now()
	p.start()
	p.wait()
	en=now()

	res=clean(f"""
		time: {descTime(en-st)}
		process id: {p.pid}
		{p.descEC()}
	""")
	ec=p.ec

def serial():
	global res,ec
	pl=SP.multiple(d.command)
	lp=pl[len(pl)-1]

	st=now()
	for p in pl:
		p.start()
		p.wait()
		if p.ec!=0:
			lp=p
			break
	en=now()

	res=linesep.join([
		f"time: {descTime(en-st)}",
		*[
			f"process{p.order} id: {p.pid if p.pid>=0 else 'N/A'}"
			for p in pl
		],
		f"exit code: {lp.ec}",""
	])
	ec=lp.ec

def spawn():
	pl=SP.multiple(d.command)

	st=now()
	for p in pl: p.start()
	for p in pl: p.wait()
	en=now()

	SP.collect(pl,st,en)

def thread():
	pl=SP.multiple(d.command)
	tl=[threading.Thread(target=lambda p: p.run(),args=(p,)) for p in pl]

	try:
		st=now()
		for t in tl: t.start()
		for t in tl: t.join()
		en=now()
	except: error("実行に失敗しました")

	SP.collect(pl,st,en)

class SP:
	popen:subprocess.Popen
	args=None
	order=0
	pid=-1
	ec=0

	def __init__(self,args):
		self.args=args

	@classmethod
	def multiple(cls,commands):
		n=1
		l=[]
		for c in commands:
			p=SP(c)
			p.order=n
			l+=[p]
			n+=1
		return l

	@classmethod
	def collect(cls,pl,st,en):
		global res,ec

		l=[f"time: {descTime(en-st)}"]
		for p in pl:
			l+=[
				f"process{p.order} id: {p.pid}",
				p.descEC()
			]
			if p.ec>ec: ec=p.ec
		l+=[""]
		res=linesep.join(l)

	def start(self):
		global o,e
		s=type(self.args) is str
		try:
			self.popen=subprocess.Popen(self.args,shell=s,stdout=o,stderr=e)
			self.pid=self.popen.pid
		except: error("実行に失敗しました")

	def wait(self):
		self.ec=self.popen.wait()

	def run(self):
		self.start()
		self.wait()

	def descEC(self):
		return f"exit code: {self.ec}"



def co2f(d:str):
	if d=="inherit": return None
	if d=="discard": return subprocess.DEVNULL
	return fh(d.out)

def ro2f(d:str):
	if d=="stdout": return stdout
	if d=="stderr": return stderr
	return fh(d)

def close(fh):
	if fh!=None:
		if type(fh) is not int: fh.close()

opened={}
def fh(path):
	if path in opened: return opened[path]
	try:
		f=open(path,"a")
		opened[path]=f
		return f
	except: error("指定したパスには書き込みできません: "+path)



def descTime(td):
	t=""
	r=td.seconds/3600
	v=floor(r)
	if v>=1: t+="{:.0f}h ".format(v)
	r=(r-v)*60
	v=floor(r)
	if v>=1: t+="{:.0f}m ".format(v)
	r=(r-v)*60
	v=floor(r)
	if v>=1: t+="{:.0f}s ".format(v)
	t+="{:07.3f}ms".format(td.microseconds/1e+3)
	return t

def descEC(ec):
	return "terminated due to signal" if ec<0 else f"exit code: {ec}"