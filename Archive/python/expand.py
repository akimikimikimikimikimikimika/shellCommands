from python.util import *

d={
	"archive":"",
	"out":"",
	"outType":"same",
	"encrypted":False,
	"suppressExpansion":False
}

class Expand:

	@classmethod
	def help(cls):
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

	@classmethod
	def main(cls):
		cls.__analyze()
		cls.__core()

	@classmethod
	def __analyze(cls):

		switches(d,[
			[["-a","-i","--archive","--in"],["var","archive"]],
			[["-d","-o","--dir","--out"],["var","out"]],
			[["--cwd"],["write","outType","cwd"],["write","out",""]],
			[["--same"],["write","outType","same"],["write","out",""]],
			[["-e","--encrypted"],["write","encrypted",True]],
			[["-s","--suppress-expansion"],["write","suppressExpansion",True]],
		],["archive"],1)

		if not isfile(d["archive"]): error("指定したパスは不正です: "+d["archive"])

		if d["outType"]=="cwd" and d["out"]=="": d["out"]=cwd
		if d["outType"]=="same" and d["out"]=="": d["out"]=getdir(d["archive"])

	@classmethod
	def __core(cls):
		t=temp()
		if isfile(d["out"]):
			if cls.__decompress(t): cls.__move(t,True)
			else:
				t.done()
				error("このファイルはこの場所には展開できません")
		elif isdir(d["out"]):
			if d["suppressExpansion"]:
				if cls.__decompress(t): cls.__move(t,True)
			else:
				if cls.__extract(t): cls.__move(t)
				elif cls.__decompress(t): cls.__move(t,True)
				else:
					t.done()
					error("このファイルは展開できません")
		elif islink(d["out"]):
			t.done()
			error("リンクが不正です: "+d["out"])
		else:
			pd=getdir(d["out"])
			if not isdir(pd):
				try: mkdir(getdir(d["out"]))
				except:
					t.done()
					error("この場所に展開できません")
			if d["suppressExpansion"]:
				if cls.__decompress(t): cls.__move(t,True)
			else:
				if cls.__extract(t): cls.__move(t)
				elif cls.__decompress(t): cls.__move(t,True)
				else:
					t.done()
					error("このファイルは展開できません")
		t.done()

	@classmethod
	def __extract(cls,t):
		done=False
		if d["encrypted"]: p=password()

		at=detect(d["archive"])
		if not done and at=="zip":
			if d["encrypted"]: pwd=p.encode("utf-8")
			else: pwd=None

			z=zf.ZipFile(file=d["archive"],mode="r")
			try:
				z.extractall(path=t.tmpDir,pwd=pwd)
				done=True
			except: pass
			z.close()
		if not done and at=="tar":
			ta=tf.open(name=d["archive"],mode="r:*")
			try:
				ta.extractall(path=ta.tmpDir)
				done=True
			except: pass
			ta.close()

		cmd=which("unzip")
		if not done and cmd!=None:
			arg=[cmd,"-qq",d["archive"],"-d",t.tmpDir]
			if d["encrypted"]:
				arg.insert(1,"-P")
				arg.insert(2,p)
			if exec(arg,True)==0: done=True

		cmd=bsdTar()
		if not done and cmd!=None:
			arg=[cmd,"-xf",d["archive"],"-C",t.tmpDir]
			if exec(arg,True)==0: done=True

		cmd=gnuTar()
		if not done and cmd!=None:
			arg=[cmd,"-xf",d["archive"],"-C",t.tmpDir]
			if exec(arg,True)==0: done=True

		cmd=which("7z")
		if not done and cmd!=None:
			arg=[cmd,"x","-t7z",d["archive"],"-o"+t.tmpDir]
			if d["encrypted"]: arg.append("-p"+p)
			if exec(arg,True)==0: done=True

		return done

	@classmethod
	def __decompress(cls,t):
		arc=concatPath(t.tmpDir,basename(d["archive"]))
		hardlink(d["archive"],arc)
		done=False
		for c in compressors:
			cmd=which(c.decompressCmd[0])
			if cmd==None: continue
			c.decompressCmd[0]=cmd
			c.decompressCmd.append(arc)
			if c.ext=="lz4":
				a=re.sub(r"\.lz4$","",arc)
				if a==arc: c.decompressCmd.append(a+".out")
				else: c.decompressCmd.append(a)
			if exec(c.decompressCmd,True)==0:
				done=True
				break
		if isfile(arc): rm(arc)
		return done

	@classmethod
	def __move(cls,t,one=False):
		fl=fileList(t.tmpDir)
		if len(fl)==1 and one:
			if isfile(d["out"]): rm(d["out"])
			if isdir(d["out"]):
				p=concatPath(d["out"],fl[0])
				if isfile(p): rm(p)
			mv(fl[0],d["out"])
		else:
			try:
				if isfile(d["out"]): error("この場所には展開できません")
				elif not isdir(d["out"]): mkdir(d["out"])
				for f in fl: mv(concatPath(t.tmpDir,f),concatPath(d["out"],f))
			except:
				error("このファイルはこの場所には展開できません")