require_relative "util.rb"

class Expand

	private
	@d={
		archive:"",
		out:"",
		outType:"same",
		encrypted:false,
		suppressExpansion:false
	}

	public

	def self.help
		helpText("""

			arc expand [archive path] [options]
			arc extract [archive path] [options]
			arc decompress [archive path] [options]

			アーカイブを展開します
			圧縮ファイルを解凍します

			オプション

			-a [string],-i [string],--archive [string],--in [string]
			 アーカイブ•圧縮ファイルを指定します

			-d [string],-o [string],--dir [string],--out [string]
			 展開する場所を指定します
			 アーカイブの場合は指定したディレクトリ内に,圧縮ファイルの場合は指定したパスに保存します
			 指定したディレクトリが存在しなければ自動的にディレクトリを生成します
			--cwd
			 カレントディレクトリに展開します
			--same
			 アーカイブファイルのあるディレクトリに展開します (デフォルト)

			-s,--suppress-expansion
			 .tar.gz など,圧縮したtarアーカイブファイルを受け取った場合に,圧縮を解凍してもtarを展開しないようにします

			-e,--encrypt
			 暗号化ファイルを展開する場合は,このオプションを使用してください
			 パスワードは後で指定します

		""")
	end

	def self.main
		analyze()
		core()
	end

	private

	def self.analyze

		switches(@d,[
			[["-a","-i","--archive","--in"],["var",:archive]],
			[["-d","-o","--dir","--out"],["var",:out]],
			[["--cwd"],["write","outType","cwd"],["write",:out,""]],
			[["--same"],["write","outType","same"],["write",:out,""]],
			[["-e","--encrypted"],["write",:encrypted,true]],
			[["-s","--suppress-expansion"],["write",:suppressExpansion,true]],
		],[:archive],1)

		error("指定したパスは不正です: "+@d[:archive]) if !isfile(@d[:archive])

		if @d[:outType]=="$cwd" && @d[:out]==""
			@d[:out]=$cwd
		end
		if @d[:outType]=="same" && @d[:out]==""
			@d[:out]=getdir(@d[:archive])
		end

	end

	def self.core
		t=Temp.new()
		if isfile(@d[:out])
			if decompress(t)
				move(t,true)
			else
				t.done()
				error("このファイルはこの場所には展開できません")
			end
		elsif isdir(@d[:out])
			if @d[:suppressExpansion]
				move(t,true) if decompress(t)
			else
				if extract(t)
					move(t)
				elsif decompress(t)
					move(t,true)
				else
					t.done()
					error("このファイルは展開できません")
				end
			end
		elsif islink(@d[:out])
			t.done()
			error("リンクが不正です: "+@d[:out])
		else
			pd=getdir(@d[:out])
			if !isdir(pd)
				begin
					mkdir(getdir(@d[:out]))
				rescue => e
					t.done()
					error("この場所に展開できません")
				end
			end
			if @d[:suppressExpansion]
				move(t,true) if decompress(t)
			else
				if extract(t)
					move(t)
				elsif decompress(t)
					move(t,true)
				else
					t.done()
					error("このファイルは展開できません")
				end
			end
		end
		t.done()
	end

	def self.extract(t)
		done=false
		p=password() if @d[:encrypted]

		cmd=which("unzip")
		if !done && cmd!=nil
			arg=[cmd,"-qq","-d",t.tmpDir,@d[:archive]]
			arg.insert(1,"-P",p) if @d[:encrypted]
			done=true if exec(arg,true)==0
		end

		cmd=bsdTar()
		if !done && cmd!=nil
			arg=[cmd,"-xf",@d[:archive],"-C",t.tmpDir]
			done=true if exec(arg,true)==0
		end

		cmd=gnuTar()
		if !done && cmd!=nil
			arg=[cmd,"-xf",@d[:archive],"-C",t.tmpDir]
			done=true if exec(arg,true)==0
		end

		cmd=which("7z")
		if !done && cmd!=nil
			arg=[cmd,"x","-t7z",@d[:archive],"-o"+t.tmpDir]
			arg.push("-p"+p) if @d[:encrypted]
			done=true if exec(arg,true)==0
		end

		return done
	end

	def self.decompress(t)
		arc=concatPath(t.tmpDir,Dir.basename(@d[:archive]))
		File.link(@d[:archive],arc)
		done=false
		compressors.each do |c|
			cmd=which(c.decompressCmd[0])
			next if cmd==nil
			c.decompressCmd[0]=cmd
			c.decompressCmd.push(arc)
			if c.ext=="lz4"
				a=arc.sub(/\.lz4$/,"")
				if a==arc
					c.decompressCmd.push(a+".out")
				else
					c.decompressCmd.push(a)
				end
			end
			if exec(c.decompressCmd,true)==0
				done=true
				break
			end
		end
		FileUtils.rm_rf(arc) if isfile(arc)
		return done
	end

	def self.move(t,one=false)
		fl=fileList(t.tmpDir)
		if fl.length==1 && one
			FileUtils.rm_rf(@d[:out]) if isfile(@d[:out])
			if isdir(@d[:out])
				p=concatPath(@d[:out],fl[0])
				FileUtils.rm_rf(p) if isfile(p)
			end
			FileUtils.mv(fl[0],@d[:out])
		else
			begin
				if isfile(@d[:out])
					error("この場所には展開できません")
				elsif !isdir(@d[:out])
					mkdir(@d[:out])
				end
				fl.each do |f|
					FileUtils.mv(concatPath(t.tmpDir,f),concatPath(@d[:out],f))
				end
			rescue => e
				error("このファイルはこの場所には展開できません")
			end
		end
	end

end