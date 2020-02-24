from python.util import *

d={
	"archive":"",
	"inFile":[],
	"type":"zip",
	"mode":"default",
	"level":"default",
	"format":"default",
	"single":False,
	"excludeHiddenFiles":True,
	"encrypted":None,
	"encryptType":"default",
	"prior":None
}

def help():
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
	 生成方法を指定します (シェルコマンド,Python)
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
	  py  Python標準のzipライブラリ

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
	  py     Python標準のtarライブラリ

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

def create(a):

	analyze(a)

	if d["type"]=="zip": Zip.run()
	elif d["type"]=="tar": Tar.run()
	elif d["type"]=="7z": p7z.run()
	else: error("アーカイブタイプが不正です: "+d["type"])

def analyze(a):

	if a=="create": i=["archive","inFile"]
	if a=="compress": i=["inFile"]

	p=[
		[["-a","-o","--archive","--out"],["var","archive"]],
		[["-i","--in"],["var","inFile",True]],
		[["-t","--type"],["var","type"]],
		[["-m","--mode"],["var","mode"]],
		[["-l","--level"],["var","level"]],
		[["-#"],["write","level"]],
		[["-f","--format"],["var","format"]],
		[["-p","--prior"],["var","prior"]],
		[["-s","--single"],["write","single",True]],
		[["--include-hidden-files"],["write","excludeHiddenFiles",False]],
		[
			["-e","--encrypt"],
			["write","encrypted",True],
			["var","encryptType"]
		]
	]

	for c in compressors:
		l=[]
		for k in c[0]: l.append("--"+k)
		p.append([l,["write","type",c[0][0]]])

	switches(d,p,i)

	for c in compressors:
		match=False
		for k in c[0]:
			if k==d["type"]: match=True
		if match:
			d["type"]="tar"
			d["mode"]=c[0][0]
			d["single"]=True
			break

	ad=d["archive"]
	while not isdir(ad): ad=getdir(ad)
	if not writable(ad): error("この場所には保存できません")

class Zip:

	run7z=None
	runZip=None
	runTar=None
	runPy=None

	@classmethod
	def run(cls):

		cls.run7z=which("7z")
		cls.runZip=which("zip")
		cls.runTar=bsdTar()
		cls.runPy="python"

		m=cls.__modeAnalyze()
		l=levelCast(d["level"])
		e=cls.__encryptionAnalyze()
		archiveAnalyze("zip")

		if d["prior"]=="7z" and cls.run7z!=None: cls.__7zCmd(cls.run7z,m[0],l[1],e[0])
		elif d["prior"]=="zip" and cls.runZip!=None: cls.__zipCmd(cls.runZip,m[1],l[0])
		elif d["prior"]=="tar" and cls.runTar!=None: cls.__tarCmd(cls.runTar,m[2],e[2])
		elif d["prior"]=="py" and cls.runPy!=None: cls.__py(m[3],int(l[0]))
		elif cls.run7z!=None: cls.__7zCmd(cls.run7z,m[0],l[1],e[0])
		elif cls.runZip!=None: cls.__zipCmd(cls.runZip,m[1],l[0])
		elif cls.runTar!=None: cls.__tarCmd(cls.runTar,m[2],e[2])
		elif cls.runPy!=None: cls.__py(m[3],int(l[0]))
		else: error("条件に合致したzipを生成する手段が見つかりませんでした")

	@classmethod
	def __modeAnalyze(cls):
		ms=d["mode"]

		if ms=="store" or ms=="copy" or ms=="default":
			m=("Copy","store","store",zf.ZIP_STORED)
		elif ms=="gz" or ms=="deflate":
			m=("Deflate","deflate","deflate",zf.ZIP_DEFLATED)
		elif ms=="deflate64":
			m=("Deflate64","deflate","deflate",zf.ZIP_DEFLATED)
		elif ms=="bz" or ms=="bzip2":
			m=("BZip2","bzip2",zf.ZIP_BZIP2)
			cls.runTar=None
		elif ms=="xz" or ms=="lzma":
			m=("LZMA","","",zf.ZIP_LZMA)
			cls.runZip=cls.runTar=None
		elif ms=="ppmd":
			m=("PPMd","","",zf.ZIP_LZMA)
			cls.runZip=cls.runTar=cls.runPy=False
		else:
			m=("Copy","store","store",zf.ZIP_STORED)

		return m

	@classmethod
	def __encryptionAnalyze(cls):
		if d["encrypted"]:
			cls.runPy=None
			es=d["encryptType"]
			if es=="zipcrypto" or es=="default":
				e=("ZipCrypto","-e","zipcrypt")
			elif es=="aes128":
				e=("AES128","","aes128")
				cls.runZip=None
			elif es=="aes192":
				e=("AES192","","aes256")
				cls.runZip=None
			elif es=="aes256":
				e=("AES256","","aes256")
				cls.runZip=None
		else: e=(None,None,None)

		return e

	@classmethod
	def __7zCmd(cls,cmd,m,l,e):
		tmp=temp()
		ap=tmp.tmpDir+"/.archive"
		if len(d["inFile"])>0:
			arg=[cmd,"a","-tzip",ap,"-sas","-xr!.DS_Store","-mx="+l,"-mm="+m]
			if d["encrypted"]:
				p=password()
				arg.extend(["-mem="+e,"-p"+p])
			arg.extend(d["inFile"])
			if exec(arg,True)!=0:
				tmp.done()
				error("7zでエラーが発生しました")
		else:
			chdir(tmp.tmpDir)
			tmp.blank()
			exec([cmd,"a","-tzip",ap,".blank"],True)
			exec([cmd,"d","-tzip",ap,".blank"],True)
			chdir(cwd)
		mv(ap,d["archive"])
		tmp.done()

	@classmethod
	def __zipCmd(cls,cmd,m,l):
		tmp=temp()
		ap=tmp.tmpDir+"/.archive"
		if len(d["inFile"])>0:
			arg=[cmd,ap,"-qr"]
			arg.extend(d["inFile"])
			if m=="deflate" or m=="bzip2": arg.append("-"+l)
			if d["encrypted"]: arg.append("-e")
			arg.extend(["-x",".DS_Store"])
			arg.extend(["-Z",m])
			if exec(arg)!=0:
				tmp.done()
				error("zipでエラーが発生しました")
		else:
			chdir(tmp.tmpDir)
			tmp.blank()
			exec([cmd,"-q",ap,".blank"],True)
			exec([cmd,"-dq",ap,".blank"],True)
			chdir(cwd)
		mv(ap,d["archive"])
		tmp.done()

	@classmethod
	def __tarCmd(cls,cmd,m,e):
		tmp=temp()
		ap=tmp.tmpDir+"/.archive.zip"

		arg=[cmd,"-a","-cf",ap,"--options","zip:compression="+m]
		if d["encrypted"]: arg[5]+=",zip:encryption="+e
		arg.extend(["--exclude",".DS_Store"])

		if len(d["inFile"])>0:
			arg.extend(d["inFile"])
			if exec(arg)!=0:
				tmp.done()
				error("tarでエラーが発生しました")
		else:
			chdir(tmp.tmpDir)
			tmp.blank()
			arg.extend(["--exclude",".blank",".blank"])
			exec(arg,True)
			chdir(cwd)
		mv(ap,d["archive"])
		tmp.done()

	@classmethod
	def __py(cls,m,l):
		z=zf.ZipFile(file=d["archive"],mode="w",compression=m,compresslevel=l)
		for i in d["inFile"]: z.write(i)
		z.close()

class Tar:

	runBTar=None
	runGTar=None
	run7z=None
	runPy=None

	@classmethod
	def run(cls):

		cls.runBTar=bsdTar()
		cls.runGTar=gnuTar()
		cls.run7z=which("7z")
		cls.runPy="python"

		m=cls.__modeAnalyze()
		l=levelCast(d["level"])
		f=cls.__formatAnalyze()

		if len(d["inFile"])==1 and d["single"]:
			f=d["inFile"][0]
			if isfile(f):
				archiveAnalyze(m[3])
				cls.__comp(f,m,l)
				return None

		archiveAnalyze(m[1])

		p=d["prior"]
		if (p=="bsdtar" or p=="tar") and cls.runBTar!=None: cls.__tarCmd(cls.runBTar,m,l)
		elif p=="gnutar" and cls.runGTar!=None: cls.__tarCmd(cls.runGTar,m,l)
		elif p=="7z" and cls.run7z!=None: cls.__7zCmd(cls.run7z,m,l)
		elif p=="py" and cls.runPy!=None: cls.__py(f[1])
		elif cls.runBTar!=None: cls.__tarCmd(cls.runBTar,m,l)
		elif cls.runGTar!=None: cls.__tarCmd(cls.runGTar,m,l)
		elif cls.run7z!=None: cls.__7zCmd(cls.run7z,m,l)
		elif cls.runPy!=None: cls.__py(f[1])
		else: error("条件に合致したtarを生成する手段が見つかりませんでした")

	@classmethod
	def __modeAnalyze(cls):
		ms=d["mode"]

		if ms=="store" or ms=="copy" or ms=="default":
			m=([],"tar",None,"")
		else:
			match=False
			for c in compressors:
				for k in c[0]:
					if k==ms: match=True
				if match:
					m=c
					break
			if not match: m=([],"tar",None,"")

		if m[2]!=None:
			c=which(m[2][0])
			if c!=None: m[2][0]=c
			else: error(f"コマンド {m[2][0]} が利用できないため実行できません")

		return m

	@classmethod
	def __formatAnalyze(cls):
		fs=d["format"]

		if fs=="default":
			f=("pax",tf.DEFAULT_FORMAT)
		elif fs=="cpio":
			f=("cpio",0)
			cls.runGTar=cls.runPy=None
		elif fs=="shar":
			f=("shar",0)
			cls.runGTar=cls.runPy=None
		elif fs=="ustar":
			f=("ustar",tf.USTAR_FORMAT)
		elif fs=="gnu":
			f=("gnu",tf.GNU_FORMAT)
		elif fs=="pax":
			f=("pax",tf.PAX_FORMAT)
		else:
			f=("pax",tf.DEFAULT_FORMAT)

		return f

	@classmethod
	def __7zCmd(cls,cmd,m,l):
		tmp=temp()
		ap=tmp.tmpDir+"/.archive"
		if len(d["inFile"])>0:
			arg=[cmd,"a","-ttar",ap,"-sas"]
			if d["excludeHiddenFiles"]: arg.append("-xr!.DS_Store")
			arg.extend(d["inFile"])
			if exec(arg,True)!=0:
				tmp.done()
				error("7zでエラーが発生しました")
		else:
			chdir(tmp.tmpDir)
			tmp.blank()
			exec([cmd,"a","-ttar",ap,".blank"],True)
			exec([cmd,"d","-ttar",ap,".blank"],True)
			chdir(cwd)
		if m[2]!=None:
			cls.__compress(m[2],l,ap,tmp)
			mv(ap+"."+m[3],d["archive"])
		else: mv(ap+m[3],d["archive"])
		tmp.done()

	@classmethod
	def __tarCmd(cls,cmd,m,l):
		tmp=temp()
		ap=tmp.tmpDir+"/.archive"

		arg=[cmd,"-cf",ap]
		if d["excludeHiddenFiles"]:
			arg.extend(["--exclude",".DS_Store"])
			env["COPYFILE_DISABLE"]="1"

		if len(d["inFile"])>0:
			arg.extend(d["inFile"])
			if exec(arg,True)!=0:
				tmp.done()
				error("tarでエラーが発生しました")
		else:
			chdir(tmp.tmpDir)
			tmp.blank()
			arg.extend(["--exclude",".blank",".blank"])
			exec(arg,True)
			chdir(cwd)
		if m[2]!=None:
			cls.__compress(m[2],l,ap,tmp)
			mv(ap+"."+m[3],d["archive"])
		else: mv(ap+m[3],d["archive"])
		tmp.done()

	@classmethod
	def __py(cls,f,m,l):
		if m[2]!=None:
			tmp=temp()
			p=tmp.tmpDir+"/.archive"
		else: p=d["archive"]
		t=tf.open(name=p,mode="w",format=f)
		for i in d["inFile"]: t.add(name=i)
		t.close()
		if m[2]!=None:
			cls.__compress(m[2],l,p,tmp)
			mv(p+"."+m[3],d["archive"])
			tmp.done()

	@classmethod
	def __comp(cls,f,m,l):
		if m[2]!=None:
			fn=basename(f)
			tmp=temp()
			tf=tmp.tmpDir+"/"+fn
			hardlink(f,tf)
			cls.__compress(m[2],l,tf,tmp)
			mv(tf+"."+m[3],d["archive"])
			tmp.done()
		else: cp(f,d["archive"])

	@classmethod
	def __compress(cls,m,l,ap,tmp):
		cmd=basename(m[0])
		if cmd=="lz4": m.append("-"+l[2])
		elif cmd=="zstd": m.append("-"+l[3])
		elif cmd!="compress": m.append("-"+l[0])
		m.append(ap)
		if cmd=="lz4": m.append(ap+".lz4")
		if exec(m,True)!=0:
			tmp.done()
			error(f"コマンド \"{cmd}\" でエラーが発生しました")

	'''
		if ms=="store" or ms=="copy" or ms=="default":
			m=("tar",None,"")
		elif ms=="z" or ms=="Z" or ms=="compress" or ms=="lzw":
			m=("tar.Z",["compress","-f"],"Z")
			# cls.run7z=cls.runPy=None
		elif ms=="gz" or ms=="gzip" or ms=="deflate":
			m=("tgz",["gzip","-f","-k"],"gz")
			# cls.run7z=cls.runPy=None
		elif ms=="bz" or ms=="bz2" or ms=="bzip" or ms=="bzip2":
			m=("tbz2",["bzip2","-z","-f","-k"],"bz2")
			# cls.run7z=cls.runPy=None
		elif ms=="xz" or ms=="lzma":
			m=("txz",["xz","-z","-f","-k","-T0"],"xz")
			# cls.run7z=cls.runPy=None
		elif ms=="lz" or ms=="lzip":
			m=("tlz",["lzip","-f","-k"],"lz")
			# cls.run7z=cls.runPy=None
			# cls.runBTar=None
		elif ms=="lzo" or ms=="lzop":
			m=("tar.lzo",["lzop","-f"],"lzo")
			# cls.run7z=cls.runPy=None
		elif ms=="lz4":
			m=("tar.lz4",["lz4","-f"],"lz4")
			# cls.run7z=cls.runPy=None
			# cls.runGTar=None
		elif ms=="br" or ms=="brotli":
			m=("tar.br",["br","-f"],"br")
			# cls.run7z=cls.runPy=None
			# cls.runBTar==cls.runGTar=None
		elif ms=="zst" or ms=="zstd" or ms=="zstandard":
			m=("tar.zst",["zstd","-f","-T0"],"zst")
			# cls.run7z=cls.runPy=None
			# cls.runBTar=None
		else:
			m=("tar",None,"")
	'''

class p7z:

	run7z=None
	runTar=None

	@classmethod
	def run(cls):

		cls.run7z=which("7z")
		cls.runTar=bsdTar()

		m=cls.__modeAnalyze()
		l=levelCast(d["level"])
		he=False
		if d["encrypted"]:
			cls.runTar=False
			if d["encryptType"]=="he": he=True
		archiveAnalyze("7z")

		if d["prior"]=="7z" and cls.run7z!=None: cls.__7zCmd(cls.run7z,m,l[1],he)
		elif d["prior"]=="tar" and cls.runTar!=None: cls.__tarCmd(cls.runTar)
		elif cls.run7z!=None: cls.__7zCmd(cls.run7z,m,l[1],he)
		elif cls.runTar!=None: cls.__tarCmd(cls.runTar)
		else: error("条件に合致した7zを生成する手段が見つかりませんでした")

	@classmethod
	def __modeAnalyze(cls):
		ms=d["mode"]

		if ms=="store" or ms=="copy": m="Copy"
		elif ms=="gz" or ms=="deflate": m="Deflate"
		elif ms=="bz" or ms=="bzip2": m="BZip2"
		elif ms=="xz" or ms=="lzma": m="LZMA"
		elif ms=="lzma2" or ms=="default": m="LZMA2"
		else: m="LZMA2"

		return m

	@classmethod
	def __7zCmd(cls,cmd,m,l,he):
		tmp=temp()
		ap=tmp.tmpDir+"/.archive"
		if len(d["inFile"])>0:
			arg=[cmd,"a","-t7z",ap,"-sas","-xr!.DS_Store","-mx="+l,"-m0="+m]
			if d["encrypted"]:
				p=password()
				arg.append("-p"+p)
				if he: arg.append("-mhe=on")
			arg.extend(d["inFile"])
			if exec(arg,True)!=0:
				tmp.done()
				error("7zでエラーが発生しました")
		else:
			chdir(tmp.tmpDir)
			tmp.blank()
			exec([cmd,"a","-t7z",ap,".blank"],True)
			exec([cmd,"d","-t7z",ap,".blank"],True)
			chdir(cwd)
		mv(ap,d["archive"])
		tmp.done()

	@classmethod
	def __tarCmd(cls,cmd):
		tmp=temp()
		ap=tmp.tmpDir+"/.archive.7z"

		arg=[cmd,"-a","-cf",ap]
		arg.extend(["--exclude",".DS_Store"])

		if len(d["inFile"])>0:
			arg.extend(d["inFile"])
			if exec(arg)!=0:
				tmp.done()
				error("tarでエラーが発生しました")
		else:
			chdir(tmp.tmpDir)
			tmp.blank()
			arg.extend(["--exclude",".blank",".blank"])
			exec(arg,True)
			chdir(cwd)
		mv(ap,d["archive"])
		tmp.done()

def archiveAnalyze(ext):
	if ext!="": ext="."+ext
	if len(d["inFile"])==1: f=d["inFile"][0]+ext
	else: f="Archive"+ext
	if d["archive"]=="": d["archive"]=f
	if isdir(d["archive"]): d["archive"]+="/"+f