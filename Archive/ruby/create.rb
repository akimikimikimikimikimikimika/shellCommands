require_relative "util.rb"

class Create

	private

	@d={
		archive:nil,
		inFile:[],
		type:"zip",
		mode:"default",
		level:"default",
		format:"default",
		single:false,
		excludeHiddenFiles:true,
		encrypted:false,
		encryptType:"default",
		prior:nil
	}

	public

	def self.help()
		helpText("""

			arc create [archive path] [options] [input file paths]...
			arc compress [input file path]... [options]

			アーカイブを生成します
			生成するにあたり,コンピュータで利用可能な方法を選択して実行します
			オプションによってはいずれの方法でも生成できない場合があり,その時にはエラーを返します

			オプション

			[input file path]...
			-i [string]...,--in [string]...
			 アーカイブに含めるファイルを指定します

			[archive path]
			-a [string],-o [string],--archive [string],--out [string]
			 生成するアーカイブファイルの保存場所を指定します

			-t [enum],--type [enum]
			 アーカイブの種類を指定します
			 zip  zipアーカイブ (--zip,デフォルト)
			 tar  tarアーカイブ (--tar)
			 7z   7zアーカイブ (--7z)
			 この他にも対応しているフォーマットがあります。詳しくは後述

			-p [enum],--prior [enum]
			 生成方法を指定します (シェルコマンド)
			 アーカイブの種類によって利用可能な生成方法は異なります (後述)
			 指定したオプション次第では指定した方法では生成されないことがあります

			-#,-l [int],--level [int]
			 圧縮率を指定します
			 1~9 の整数で指定し,数値が大きいと圧縮率が高くなります
			 デフォルトは6
			 ※ tarオプションでは例外があります
			  -m lz4 の場合は 1~12 で指定し,デフォルトは1です
			  -m zstd の場合は 1~19 で指定し,デフォルトは3です
			  -m stored の場合はこのオプションは無効です
			  -m compress の場合はこのオプションは無効です

			zipアーカイブのオプション

			 生成方法 (優先順)
			  7z  7zコマンド
			  zip zipコマンド
			  tar tarコマンド

			 -m [enum],--mode [enum]
			  圧縮モードを指定します
			  store,copy  非圧縮 (デフォルト)
			  gz,deflate  Deflate圧縮
			  bz,bzip2    BZIP2圧縮
			  xz,lzma     LZMA圧縮

			 -e,--encrypt [enum]
			  アーカイブを暗号化します
			  パスワードは後で指定します
			  [enum] に次のうちいずれかの値を指定した暗号化の方法を指定できます
			   zipcrypto ZIP標準の暗号システム (デフォルト)
			   aes128    AES128暗号
			   aes192    AES192暗号
			   aes256    AES256暗号

			tarアーカイブのオプション

			 生成方法 (優先順)
			  tar    tarコマンド
			  gnutar gtarコマンド
			  7z     7zコマンド

			 -m [enum],--mode [enum]
			  圧縮モードを指定します
			  store,copy  非圧縮 (.tar,デフォルト)
			  gz,deflated Deflate圧縮 (.tar.gz)
			  bz,bzip2    BZIP2圧縮 (.tar.bz2)
			  xz,lzma     LZMA圧縮 (.tar.xz)
			  lzip        LZIP圧縮 (.tar.lz)
			  lzop        LZOP圧縮 (.tar.lzop)
			  lz4         LZ4圧縮 (.tar.lz4)
			  brotli      Brotli圧縮 (.tar.br)
			  zstd        Zstandard圧縮 (.tar.zst)

			 -f [enum],--format [enum]
			  tarのフォーマットを指定します
			  cpio  cpioフォーマット
			  shar  sharフォーマット
			  ustar ustarフォーマット
			  gnu   GNU tarフォーマット
			  pax   paxフォーマット (デフォルト)

			 -s,--single
			  -i で単一のファイルを指定した場合には,tarでアーカイブにせず圧縮ファイルを生成します。
			  例えば, -m gz とした場合, file は file.tar.gz ではなく file.gz になります。
			  -m store の場合はファイルが単純にコピーされます。

			 --include-hidden-files
			  macOSの隠しファイルもアーカイブします
			  これらにはFinderで使用されるデータも含み,展開時にそれらが復元されますが,他のプラットフォームでは可視ファイルとして展開されます

			7zアーカイブのオプション

			 生成方法 (優先順)
			  7z  7zコマンド
			  tar tarコマンド

			 -m [enum],--mode [enum]
			  圧縮モードを指定します
			  stored,copy 非圧縮
			  gz,deflate  Deflate圧縮
			  bz,bzip2    BZIP2圧縮
			  xz,lzma     LZMA圧縮
			  lzma2       LZMA2圧縮 (デフォルト)

			 -e,--encrypt
			  アーカイブを暗号化します
			  パスワードは後で指定します

			 -e he,--encrypt he
			  暗号化するにあたって,ヘッダも暗号化します
			  これにより, arc paths などでファイルの中身を表示できなくなります

			-tオプションで指定可能な値
			 zip   zipアーカイブ (--zip)
			 tar   tarアーカイブ (--tar)
			 7z    7zアーカイブ (--7z)

			 gzip  Gzip      (-t tar -m gzip -s と同等)
			 bzip2 Bzip2     (-t tar -m bzip2 -s と同等)
			 xz    xz        (-t tar -m xz -s と同等)
			 lzip  Lzip      (-t tar -m lzip -s と同等)
			 lzop  Lzop      (-t tar -m lzop -s と同等)
			 lz4   Lz4       (-t tar -m lz4 -s と同等)
			 br    Brotli    (-t tar -m brotli -s と同等)
			 zstd  Zstandard (-t tar -m zstd -s と同等)

			 --gzip,--bzip2,... などでも指定可能

		""")
	end

	def self.main(a)

		analyze(a)

		case @d[:type]
			when "zip"
				Zip.run(@d)
			when "tar"
				Tar.run(@d)
			when "7z"
				Sz.run(@d)
			else
				error("アーカイブタイプが不正です: "+@d[:type])
		end

	end

	private

	def self.analyze(a)

		case a
			when "create"
				i=[:archive,:inFile]
			when "compress"
				i=[:inFile]
		end

		p=[
			[["-a","-o","--archive","--out"],["var",:archive]],
			[["-i","--in"],["var",:inFile,true]],
			[["-t","--type"],["var",:type]],
			[["-m","--mode"],["var",:mode]],
			[["-l","--level"],["var",:level]],
			[["-#"],["write",:level]],
			[["-f","--format"],["var",:format]],
			[["-p","--prior"],["var",:prior]],
			[["-s","--single"],["write",:single,true]],
			[["--include-hidden-files"],["write",:excludeHiddenFiles,false]],
			[
				["-e","--encrypt"],
				["write",:encrypted,true],
				["var",:encryptType]
			],
			[["--zip"],["write",:type,"zip"]],
			[["--tar"],["write",:type,"tar"]],
			[["--7z"],["write",:type,"7z"]]
		]

		$compressors.each do |c|
			l=c.keys.map {|k| "--"+k }
			p.push([l,["write",:type,c.keys[0]]])
		end

		switches(@d,p,i)

		$compressors.each do |c|
			match=false
			c.keys.each do |k|
				match=true if k==@d[:type]
			end
			if match
				@d[:type]="tar"
				@d[:mode]=c.keys[0]
				@d[:single]=true
				break
			end
		end

		ad=@d[:archive]
		if ad!=nil
			while !isdir(ad)
				ad=getdir(ad)
			end
			if !File.writable?(ad)
				error("この場所には保存できません")
			end
		end

	end

	class Zip

		private
		@run7z=nil
		@runZip=nil
		@runTar=nil
		@d=nil

		public
		def self.run(d)
			@d=d

			@run7z=which("7z")
			@runZip=which("zip")
			@runTar=bsdTar()

			m=modeAnalyze()
			l=levelCast(@d[:level])
			e=encryptionAnalyze()
			Create::archiveAnalyze("zip")

			p=@d[:prior]
			if p=="7z" && @run7z!=nil
				szCmd(@run7z,m[0],l[1],e[0])
			elsif p=="zip" && @runZip!=nil
				zipCmd(@runZip,m[1],l[0])
			elsif p=="tar" && @runTar!=nil
				tarCmd(@runTar,m[2],e[2])
			elsif @run7z!=nil
				szCmd(@run7z,m[0],l[1],e[0])
			elsif @runZip!=nil
				zipCmd(@runZip,m[1],l[0])
			elsif @runTar!=nil
				tarCmd(@runTar,m[2],e[2])
			else
				error("条件に合致したzipを生成する手段が見つかりませんでした")
			end

		end

		private

		def self.modeAnalyze()
			ms=@d[:mode]

			case ms
				when "store","copy","default"
					m=["Copy","store","store"]
				when "gz","deflate"
					m=["Deflate","deflate","deflate"]
				when "deflate64"
					m=["Deflate64","deflate","deflate"]
				when "bz","bzip2"
					m=["BZip2","bzip2"]
					@runTar=nil
				when "xz","lzma"
					m=["LZMA","",""]
					@runZip=@runTar=nil
				when "ppmd"
					m=["PPMd","",""]
					@runZip=@runTar=nil
				else
					m=["Copy","store","store"]
			end

			m
		end

		def self.encryptionAnalyze()
			if @d[:encrypted]
				case @d["encryptType"]
					when "zipcrypto","default"
						e=["ZipCrypto","-e","zipcrypt"]
					when "aes128"
						e=["AES128","","aes128"]
						@runZip=nil
					when "aes192"
						e=["AES192","","aes256"]
						@runZip=nil
					when "aes256"
						e=["AES256","","aes256"]
						@runZip=nil
					else
						e=["ZipCrypto","-e","zipcrypt"]
				end
			else
				e=[nil,nil,nil]
			end

			e
		end

		def self.szCmd(cmd,m,l,e)
			tmp=Temp.new()
			ap=concatPath(tmp.tmpDir,".archive")
			if @d[:inFile].length>0
				arg=[cmd,"a","-tzip",ap,"-sas","-xr!.DS_Store","-mx="+l,"-mm="+m]
				if @d[:encrypted]
					p=password()
					arg.push("-mem="+e,"-p"+p)
				end
				arg=arg.union(@d[:inFile])
				if exec(arg,true)!=0
					tmp.done()
					error("7zでエラーが発生しました")
				end
			else
				Dir.chdir(tmp.tmpDir)
				tmp.blank()
				exec([cmd,"a","-tzip",ap,".blank"],true)
				exec([cmd,"d","-tzip",ap,".blank"],true)
				Dir.chdir($cwd)
			end
			FileUtils.mv(ap,@d[:archive])
			tmp.done()
		end

		def self.zipCmd(cmd,m,l)
			tmp=Temp.new()
			ap=concatPath(tmp.tmpDir,".archive")
			if @d[:inFile].length>0
				arg=[cmd,ap,"-qr"]
				arg=arg.union(@d[:inFile])
				arg.append("-"+l) if m=="deflate" || m=="bzip2"
				arg.push("-p",password()) if @d[:encrypted]
				arg.push("-x",".DS_Store")
				arg.push("-Z",m)
				if exec(arg)!=0
					tmp.done()
					error("zipでエラーが発生しました")
				end
			else
				Dir.chdir(tmp.tmpDir)
				tmp.blank()
				exec([cmd,"-q",ap,".blank"],true)
				exec([cmd,"-dq",ap,".blank"],true)
				Dir.chdir($cwd)
			end
			FileUtils.mv(ap,@d[:archive])
			tmp.done()
		end

		def self.tarCmd(cmd,m,e)
			tmp=Temp.new()
			ap=concatPath(tmp.tmpDir,".archive.zip")

			arg=[cmd,"-a","-cf",ap,"--options","zip:compression="+m]
			arg[5]+=",zip:encryption="+e if @d[:encrypted]
			arg.push("--exclude",".DS_Store")

			if @d[:inFile].length>0
				arg=arg.union(@d[:inFile])
				if exec(arg)!=0
					tmp.done()
					error("tarでエラーが発生しました")
				end
			else
				Dir.chdir(tmp.tmpDir)
				tmp.blank()
				arg.push("--exclude",".blank",".blank")
				exec(arg,true)
				Dir.chdir($cwd)
			end
			FileUtils.mv(ap,@d[:archive])
			tmp.done()
		end

	end

	class Tar

		private
		@runBTar=nil
		@runGTar=nil
		@run7z=nil
		@d=nil

		public
		def self.run(d)
			@d=d

			@runBTar=bsdTar()
			@runGTar=gnuTar()
			@run7z=which("7z")

			m=modeAnalyze()
			l=levelCast(@d[:level])
			f=formatAnalyze()

			if @d[:inFile].length==1 && @d[:single]
				sf=@d[:inFile][0]
				if isfile(sf)
					Create::archiveAnalyze(m.ext)
					comp(sf,m,l)
					return nil
				end
			end

			Create::archiveAnalyze(m.tarExt)

			p=@d[:prior]
			if (p=="bsdtar" || p=="tar") && @runBTar!=nil
				tarCmd(@runBTar,m,l,f)
			elsif p=="gnutar" && @runGTar!=nil
				tarCmd(@runGTar,m,l,f)
			elsif p=="7z" && @run7z!=nil
				szCmd(@run7z,m,l)
			elsif @runBTar!=nil
				tarCmd(@runBTar,m,l,f)
			elsif @runGTar!=nil
				tarCmd(@runGTar,m,l,f)
			elsif @run7z!=nil
				szCmd(@run7z,m,l)
			else
				error("条件に合致したtarを生成する手段が見つかりませんでした")
			end

		end

		private

		def self.modeAnalyze()
			ms=@d[:mode]
			m=CompressType.new([[],"tar",nil,"",nil])

			if ms!="store" && ms!="copy" && ms!="default"
				$compressors.each do |c|
					match=false
					c.keys.each do |k|
						match=true if k==ms
					end
					if match
						m=c
						break
					end
				end
			end

			if m.compressCmd!=nil
				c=which(m.compressCmd[0])
				if c!=nil
					m.compressCmd[0]=c
				else
					error("コマンド \"#{m.compressCmd[0]}\" が利用できないため実行できません")
				end
			end

			m
		end

		def self.formatAnalyze()

			case @d[:format]
				when "default"
					f="pax"
				when "cpio"
					f="cpio"
					@runGTar=nil
				when "shar"
					f="shar"
					@runGTar=nil
				when "ustar"
					f="ustar"
				when "gnu"
					f="gnu"
					@runBTar=nil
				when "pax"
					f="pax"
				else
					f="pax"
			end

			f
		end

		def self.szCmd(cmd,m,l)
			tmp=Temp.new()
			ap=concatPath(tmp.tmpDir,".archive")
			if @d[:inFile].length>0
				arg=[cmd,"a","-ttar",ap,"-sas"]
				if @d[:excludeHiddenFiles]
					arg.push("-xr!.DS_Store")
				end
				arg=arg.union(@d[:inFile])
				if exec(arg,true)!=0
					tmp.done()
					error("7zでエラーが発生しました")
				end
			else
				Dir.chdir(tmp.tmpDir)
				tmp.blank()
				exec([cmd,"a","-ttar",ap,".blank"],true)
				exec([cmd,"d","-ttar",ap,".blank"],true)
				Dir.chdir($cwd)
			end
			if m.compressCmd!=nil
				compress(m.compressCmd,l,ap,tmp)
				FileUtils.mv(ap+"."+m.ext,@d[:archive])
			else
				FileUtils.mv(ap,@d[:archive])
			end
			tmp.done()
		end

		def self.tarCmd(cmd,m,l,f)
			tmp=Temp.new()
			ap=concatPath(tmp.tmpDir,".archive")

			arg=[cmd,"-cf",ap,"--format",f]
			if @d[:excludeHiddenFiles]
				arg.push("--exclude",".DS_Store")
				$env["COPYFILE_DISABLE"]="1"
			end

			if @d[:inFile].length>0
				arg=arg.union(@d[:inFile])
				if exec(arg,true)!=0
					tmp.done()
					error("tarでエラーが発生しました")
				end
			else
				Dir.chdir(tmp.tmpDir)
				tmp.blank()
				arg.push("--exclude",".blank",".blank")
				exec(arg,true)
				Dir.chdir($cwd)
			end
			if m.compressCmd!=nil
				compress(m.compressCmd,l,ap,tmp)
				FileUtils.mv(ap+"."+m.ext,@d[:archive])
			else
				FileUtils.mv(ap,@d[:archive])
			end
			tmp.done()
		end

		def self.comp(f,m,l)
			if m.compressCmd!=nil
				fn=File.basename(f)
				tmp=Temp.new()
				tf=concatPath(tmp.tmpDir,fn)
				File.link(f,tf)
				compress(m.compressCmd,l,tf,tmp)
				FileUtils.mv(tf+"."+m.ext,@d[:archive])
				tmp.done()
			else
				FileUtils.cp(f,@d[:archive])
			end
		end

		def self.compress(m,l,ap,tmp)
			cmd=File.basename(m[0])
			if cmd=="lz4"
				m.push("-"+l[2])
			elsif cmd=="zstd"
				m.push("-"+l[3])
			elsif cmd!="compress"
				m.push("-"+l[0])
			end
			m.push(ap)
			if cmd=="lz4"
				m.push(ap+".lz4")
			end
			if exec(m,true)!=0
				tmp.done()
				error("コマンド \"#{cmd}\" でエラーが発生しました")
			end
		end

	end

	class Sz

		private
		@run7z=nil
		@runTar=nil
		@d=nil

		public
		def self.run(d)
			@d=d

			@run7z=which("7z")
			@runTar=bsdTar()

			m=modeAnalyze()
			l=levelCast(@d[:level])
			he=false
			if @d[:encrypted]
				@runTar=false
				if @d[:encryptType]=="he" then he=true end
			end
			Create::archiveAnalyze("7z")

			p=@d[:prior]
			if p=="7z" && @run7z!=nil
				szCmd(@run7z,m,l[1],he)
			elsif p=="tar" && @runTar!=nil
				tarCmd(@runTar)
			elsif @run7z!=nil
				szCmd(@run7z,m,l[1],he)
			elsif @runTar!=nil
				tarCmd(@runTar)
			else
				error("条件に合致した7zを生成する手段が見つかりませんでした")
			end

		end

		private

		def self.modeAnalyze()
			ms=@d[:mode]

			case ms
				when "store","copy"
					m="Copy"
				when "gz","deflate"
					m="Deflate"
				when "bz","bzip2"
					m="BZip2"
				when "xz","lzma"
					m="LZMA"
				when "lzma2","default"
					m="LZMA2"
				else
					m="LZMA2"
			end

			return m
		end

		def self.szCmd(cmd,m,l,he)
			tmp=Temp.new()
			ap=concatPath(tmp.tmpDir,".archive")
			if @d[:inFile].length>0
				arg=[cmd,"a","-t7z",ap,"-sas","-xr!.DS_Store","-mx="+l,"-m0="+m]
				if @d[:encrypted]
					p=password()
					arg.push("-p"+p)
					arg.push("-mhe=on") if he
				end
				arg=arg.union(@d[:inFile])
				if exec(arg,true)!=0
					tmp.done()
					error("7zでエラーが発生しました")
				end
			else
				Dir.chdir(tmp.tmpDir)
				tmp.blank()
				exec([cmd,"a","-t7z",ap,".blank"],true)
				exec([cmd,"d","-t7z",ap,".blank"],true)
				Dir.chdir($cwd)
			end
			FileUtils.mv(ap,@d[:archive])
			tmp.done()
		end

		def self.tarCmd(cmd)
			tmp=Temp.new()
			ap=concatPath(tmp.tmpDir,".archive.7z")

			arg=[cmd,"-a","-cf",ap]
			arg.push("--exclude",".DS_Store")

			if @d[:inFile].length>0
				arg=arg.union(@d[:inFile])
				if exec(arg)!=0
					tmp.done()
					error("tarでエラーが発生しました")
				end
			else
				Dir.chdir(tmp.tmpDir)
				tmp.blank()
				arg.push("--exclude",".blank",".blank")
				exec(arg,true)
				Dir.chdir($cwd)
			end
			FileUtils.mv(ap,@d[:archive])
			tmp.done()
		end

	end

	def self.archiveAnalyze(ext)
		if ext!="" then ext="."+ext end
		if @d[:inFile].length==1
			f=@d[:inFile][0]+ext
		else
			f="Archive"+ext
		end
		if @d[:archive]==nil
			error("カレントディレクトリにアーカイブを書き出すことができません") if !File.writable?($cwd)
			@d[:archive]=f
		end
		@d[:archive]=concatPath(@d[:archive],f) if isdir(@d[:archive])
	end

end