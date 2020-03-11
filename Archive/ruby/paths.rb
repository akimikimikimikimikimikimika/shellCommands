require_relative "util.rb"

class Paths

	private

	@d={
		archive:nil
	}

	public

	def self.help()
		helpText("""

			arc paths [archive path] [options]
			arc list [archive path] [options]

			アーカイブに含まれるファイルの一覧を表示します

			オプション

			[archive path]
			-a [string],-i [string],--archive [string],--in [string]
			 アーカイブファイルを指定します

		""")
	end

	def self.main()

		switches(@d,[
			[["-a","-i","--archive","--in"],["var",:archive]]
		],[:archive],1)

		if @d[:archive]==nil
			error("アーカイブが指定されていません")
		elsif !isfile(@d[:archive])
			error("パラメータが不正です: "+@d[:archive])
		end
		if cmd()
			return nil
		end
		error("このファイルの内容を表示できません")

	end

	private

	def self.cmd()
		t=bsdTar()
		if t
			if exec([t,"-tf",@d[:archive]]) then return true end
		end
		t=gnuTar()
		if t
			if exec([t,"-tf",@d[:archive]]) then return true end
		end
		false
	end

end