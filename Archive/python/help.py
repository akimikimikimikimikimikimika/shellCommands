from python.util import error,helpText
from python.create import help as create
from python.expand import help as expand
from python.paths import help as paths

def help(args):
	if args[2]=="" or args[2]=="general" or args[2]=="help": genericHelp()
	elif args[2]=="create" or args[2]=="compress": create()
	elif args[2]=="expand" or args[2]=="extract" or args[2]=="decompress": expand()
	elif args[2]=="paths" or args[2]=="list": paths()
	else: error("指定したヘルプテキストはありません: "+args[2])

def genericHelp():
	helpText("""

	使い方:
	arc [command] [options]...

	アーカイブを取り扱います
	それぞれのコマンドの使い方は arc help [command] を参照

	arc create [archive path] [options] [input file paths]...
	arc compress [input file paths] [options]
	 アーカイブを生成します

	arc expand [archive path] [options]
	arc extract [archive path] [options]
	arc decompress [archive path] [options]
	 アーカイブを展開します

	arc paths [archive path] [options]
	arc list [archive path] [options]
	 アーカイブに含まれるファイルの一覧を表示します

	""")