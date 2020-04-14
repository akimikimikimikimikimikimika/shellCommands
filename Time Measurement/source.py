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

def argAnalyze():
	global out,err,result,multiple
	l=sys.argv[1:]
	if len(l)==0: error("引数が不足しています")
	elif l[0]=="-h" or l[0]=="help" or l[0]=="-help" or l[0]=="--help": help()
	elif l[0]=="-v" or l[0]=="version" or l[0]=="-version" or l[0]=="--version": version()
	noFlags=False
	key=None
	for a in l:
		if noFlags: command.append(a)
		elif key!=None:
			if key=="stdout": out=a
			if key=="stderr": err=a
			if key=="result": result=a
			key=None
		elif a=="-o" or a=="-our" or a=="-stdout": key="stdout"
		elif a=="-e" or a=="-err" or a=="-stderr": key="stderr"
		elif a=="-r" or a=="-result": key="result"
		elif a=="-m" or a=="-multiple": multiple=True
		else:
			noFlags=False
			command.append(a)
	if len(command)==0: error("実行する内容が指定されていません")

class execute:

	def __init__(self):
		o=self.co2f(out)
		e=self.co2f(err)
		r=self.ro2f(result)
		try:
			if multiple:
				pl=[]
				ec=0
				st=datetime.now()
				for c in command:
					pid,ec=self.run(c,o,e,True)
					pl.append(pid)
					if ec!=0: break
				en=datetime.now()
				l=[]
				l.append(f"time: {self.descTime(en-st)}")
				for n in range(0,len(pl)): l.append(f"process{n+1} id: {pl[n]}")
				l.extend([f"exit code: {ec}",""])
				r.writelines(os.linesep.join(l))
			else:
				st=datetime.now()
				pid,ec=self.run(command,o,e,False)
				en=datetime.now()
				r.write(clean(f"""
					time: {self.descTime(en-st)}
					process id: {pid}
					exit code: {ec}
				""")+os.linesep)
		except: error("実行に失敗しました")

	def co2f(self,d):
		if d=="inherit": return None
		elif d=="discard": return subprocess.DEVNULL
		else: return fh(out)

	def ro2f(self,d):
		if d=="stdout": return sys.stdout
		elif d=="stderr": return sys.stderr
		else: return fh(d)

	def fh(self,path):
		try: return open(path,"a")
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

	"""))
	exit(0)

def version():
	print(clean("""

		 measure v2.0
		 Python バージョン (measure-py)

	"""))
	exit(0)

def clean(text):
	text=re.sub(r"\n\t+","\n",text)
	text=re.sub(r"^\n","",text)
	text=re.sub(r"\n$","",text)
	return text

argAnalyze()
execute()