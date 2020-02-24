from python.help import help
from python.create import create
from python.expand import expand
from python.paths import paths
from python.util import *

def core():
    a=sys.argv
    if len(a)==2:
        if a[1]=="help" or a[1]=="-help" or a[1]=="--help": help(["","","general"])
        else: error("引数が不足しています")
    elif len(a)==1: error("引数が不足しています")
    elif a[1]=="create" or a[1]=="compress": create(a[1])
    elif a[1]=="expand" or a[1]=="extract" or a[1]=="decompress": expand()
    elif a[1]=="paths" or a[1]=="list": paths()
    elif a[1]=="help": help(a)
    else: error("コマンドが無効です: "+a[1])