#! /usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import os
import subprocess
from math import floor
import re
from datetime import datetime

command=[]
out="inherit"
err="inherit"
result="stderr"
multiple=False

def main():
	argAnalyze()
	execute()

def argAnalyze():
	global command,out,err,result,multiple
	l=sys.argv[1:]
	if len(l)==0: error("引数が不足しています")
	elif eq(l[0],"-h","help","-help","--help"): help()
	elif eq(l[0],"-v","version","-version","--version"): version()
	key=None
	for n in range(0,len(l)):
		a=l[n]
		if key!=None:
			if key==0: out=a
			if key==1: err=a
			if key==2: result=a
			key=None
		elif eq(a,"-o","-our","-stdout"): key=0
		elif eq(a,"-e","-err","-stderr"): key=1
		elif eq(a,"-r","-result"): key=2
		elif eq(a,"-m","-multiple"): multiple=True
		else:
			command=l[n:len(l)]
			break
	if len(command)==0: error("実行する内容が指定されていません")

class execute:

	def __init__(self):
		o=self.co2f(out)
		e=self.co2f(err)
		r=self.ro2f(result)
		if multiple:
			pl=[]
			ec=0
			try:
				st=datetime.now()
				for c in command:
					pid,ec=self.run(c,o,e,True)
					pl+=[pid]
					if ec!=0: break
				en=datetime.now()
			except: error("実行に失敗しました")
			l=[]
			l.append(f"time: {self.descTime(en-st)}")
			for n in range(0,len(pl)): l.append(f"process{n+1} id: {pl[n]}")
			l.extend([f"exit code: {ec}",""])
			r.writelines(os.linesep.join(l))
		else:
			try:
				st=datetime.now()
				pid,ec=self.run(command,o,e,False)
				en=datetime.now()
			except: error("実行に失敗しました")
			r.write(clean(f"""
				time: {self.descTime(en-st)}
				process id: {pid}
				exit code: {ec}
			"""))
		exit(ec)

	def co2f(self,d):
		if d=="inherit": return None
		elif d=="discard": return subprocess.DEVNULL
		else: return self.fh(out)

	def ro2f(self,d):
		if d=="stdout": return sys.stdout
		elif d=="stderr": return sys.stderr
		else: return self.fh(d)

	__opened={}
	def fh(self,path):
		if path in self.__opened: return self.__opened[path]
		try:
			f=open(path,"a")
			self.__opened[path]=f
			return f
		except: error("指定したパスには書き込みできません: "+path)

	def run(self,c,o,e,s):
		p=subprocess.Popen(c,shell=s,stdout=o,stderr=e)
		pid=p.pid
		ec=p.wait()
		return pid,ec

	def descTime(self,td):
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
		t+="{:.3f}ms".format(td.microseconds/1e+3)
		return t

def error(text):
	sys.stderr.write(text+os.linesep)
	exit(1)

def help():
	print(clean("""

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

	"""),end="")
	exit(0)

def version():
	print(clean("""

		 measure v2.1
		 Python バージョン (measure-py)

	"""),end="")
	exit(0)

def clean(text):
	text=re.sub(r"(?m)\t+","",text)
	text=re.sub(r"^\n","",text)
	return text

def eq(target,*cans):
	for c in cans:
		if c==target: return True
	return False

main()