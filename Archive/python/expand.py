from python.util import *

d={
	"archive":"",
	"out":"",
	"outType":"same",
	"encrypted":False,
	"suppressExpansion":False
}

def help():
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
	 暗号化ファイルを展開する場合は,これを使用することをおすすめします
	 パスワードは後で指定します

	""")

def expand():
	analyze()
	core()

def analyze():

	switches(d,[
		[["-a","-i","--archive","--in"],["var","archive"]],
		[["-d","-o","--dir","--out"],["var","out"]],
		[["--cwd"],["write","outType","cwd"],["write","out",""]],
		[["--same"],["write","outType","same"],["write","out",""]],
		[["-e","--encrypted"],["write","encrypted",True]],
		[["-s","--suppress-expansion"],["write","suppressExpansion",True]],
	],["archive"],1)

	if not isfile(d["archive"]): error("指定したパスは不正です: "+d["archive"])

	if d["outType"]=="cwd" and d["out"]=="": d["dir"]=cwd
	if d["outType"]=="same" and d["out"]=="": d["dir"]=getdir(d["archive"])

def core():
	t=temp()
	if isfile(d["out"]):
		if decompress(t): move(t,True)
		else:
			t.done()
			error("このファイルはこの場所には展開できません")
	elif isdir(d["out"]):
		if d["suppressExpansion"]:
			if decompress(t): move(t,True)
		else:
			if extract(t): move(t)
			elif decompress(t): move(t,True)
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
			if decompress(t): move(t,True)
		else:
			if extract(t): move(t)
			elif decompress(t): move(t,True)
			else:
				t.done()
				error("このファイルは展開できません")
	t.done()

def extract(t):
	done=False

	at=detect(d["archive"])
	if not done and at=="zip":
		pwd=None
		if d["encrypted"]:
			p=""
			while p=="": p=password()
			pwd=p.encode("utf-8")

		z=zf.ZipFile(file=d["archive"],mode="r")
		try:
			z.extractall(path=t.tmpDir,pwd=pwd)
			done=True
		except: pass
		z.close()
	if not done and at=="tar":
		t=tf.open(name=d["archive"],mode="r:*")
		try:
			t.extractall(path=t.tmpDir)
			done=True
		except: pass
		t.close()

	cmd=bsdTar()
	if not done and cmd!=None:
		arg=[cmd,"-xf",d["archive"],"-C",t.tmpDir]
		if exec(arg)==0: done=True

	cmd=gnuTar()
	if not done and cmd!=None:
		arg=[cmd,"-xf",d["archive"],"-C",t.tmpDir]
		if exec(arg)==0: done=True

	cmd=which("unzip")
	if not done and cmd!=None:
		arg=[cmd,"-qq",d["archive"],"-d",t.tmpDir]
		if exec(arg)==0: done=True

	cmd=which("7z")
	if not done and cmd!=None:
		arg=[cmd,"x","-t7z",d["archive"],"-o"+t.tmpDir]
		if exec(arg)==0: done=True

	return done

def decompress(t):
	arc=t.tmpDir+"/"+basename(d["archive"])
	hardlink(d["archive"],arc)
	done=False
	for c in compressors:
		cmd=which(c[4][0])
		if cmd==None: continue
		c[4][0]=cmd
		c[4].append(arc)
		if c[3]=="lz4":
			a=re.sub(r"\.lz4$","",arc)
			if a==arc: c[4].append(a+".out")
			else: c[4].append(a)
		if exec(c[4],True)==0:
			done=True
			break
	if isfile(arc): rm(arc)
	return done

def move(t,one=False):
	fl=fileList(t.tmpDir+"/*")
	if len(fl)==1 and one:
		if isfile(d["out"]): rm(d["out"])
		if isdir(d["out"]):
			p=d["out"]+"/"+basename(fl[0])
			if isfile(p): rm(p)
		mv(fl[0],d["out"])
	else:
		try:
			if isfile(d["out"]): error("この場所には展開できません")
			elif not isdir(d["out"]): mkdir(d["out"])
			for f in fl: mv(f,d["out"])
		except:
			print(fl)
			error("このファイルはこの場所には展開できません")