from python.help import Help
from python.create import Create
from python.expand import Expand
from python.paths import Paths
from python.util import *

def core():
	a=sys.argv[1:]
	if len(a)==1:
		if a[0]=="help" or a[0]=="-help" or a[0]=="--help": Help.main("")
		else: error("引数が不足しています")
	elif len(a)==0: error("引数が不足しています")
	elif a[0]=="create" or a[0]=="compress": Create.main(a[0])
	elif a[0]=="expand" or a[0]=="extract" or a[0]=="decompress": Expand.main()
	elif a[0]=="paths" or a[0]=="list": Paths.main()
	elif a[0]=="help": Help.main(a[1])
	else: error("コマンドが無効です: "+a[0])