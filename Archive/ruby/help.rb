require_relative "util.rb"
require_relative "create.rb"
require_relative "expand.rb"
require_relative "paths.rb"

class Help

	public

	def self.main(arg)
		case arg
			when "","general","help"
				genericHelp()
			when "create","compress"
				Create::help()
			when "expand","extract","decompress"
				Expand::help()
			when "paths","list"
				Paths::help()
			else
				error("指定したヘルプテキストはありません: "+arg)
		end
	end

	private

	def self.genericHelp()
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
	end

end