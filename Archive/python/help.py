from python.util import error,helpText
from python.create import Create
from python.expand import Expand
from python.paths import Paths

class Help:

	@classmethod
	def main(cls,arg):
		if arg=="" or arg=="general" or arg=="help": cls.__genericHelp()
		elif arg=="create" or arg=="compress": Create.help()
		elif arg=="expand" or arg=="extract" or arg=="decompress": Expand.help()
		elif arg=="paths" or arg=="list": Paths.help()
		else: error("指定したヘルプテキストはありません: "+arg)

	@classmethod
	def __genericHelp(cls):

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