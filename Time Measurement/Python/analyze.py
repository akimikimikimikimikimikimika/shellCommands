from sys import argv
from enum import Enum,auto,unique
from lib import CM,MM,data,eq,error
from docs import help,version

@unique
class Key(Enum):
	null    =auto()
	out     =auto()
	err     =auto()
	result  =auto()
	multiple=auto()

def argAnalyze(d:data):
	l=argv[1:]

	if len(l)==0: error("引数が不足しています")
	elif eq(l[0],"-h","help","-help","--help"):
		d.mode=CM.help
		return
	elif eq(l[0],"-v","version","-version","--version"):
		d.mode=CM.version
		return

	key=Key.null
	n=-1
	for a in l:
		n+=1
		if a=="": continue

		proceed=True
		if eq(a,"-m","-multiple"):
			d.multiple=MM.serial
			key=Key.multiple
		elif eq(a,"-o","-our","-stdout"): key=Key.out
		elif eq(a,"-e","-err","-stderr"): key=Key.err
		elif eq(a,"-r","-result"): key=Key.result
		elif a[0]=="-": error("不正なオプションが指定されています")
		else: proceed=False
		if proceed: continue

		if key!=Key.null:
			proceed=True
			if key==Key.out:      d.out=a
			if key==Key.err:      d.err=a
			if key==Key.result:   d.result=a
			if key==Key.multiple:
				if   eq(a,"none"): d.multiple=MM.none
				elif eq(a,"serial",""): d.multiple=MM.serial
				elif eq(a,"spawn","parallel"): d.multiple=MM.spawn
				elif eq(a,"thread"): d.multiple=MM.thread
				else: proceed=False
			key=Key.null
		if proceed: continue

		d.command=l[n:len(l)]
		break

	if len(d.command)==0: error("実行する内容が指定されていません")