from python.util import *

d={
	"archive":None
}

def help():
	helpText("""

	arc paths [archive path] [options]
	arc list [archive path] [options]

	アーカイブに含まれるファイルの一覧を表示します

	オプション

	[archive path]
	-a [string],-i [string],--archive [string],--in [string]
	 アーカイブファイルを指定します

	""")

def paths():

	switches(d,[
		[["-a","-i","--archive","--in"],["var","archive"]]
	],["archive"],1)

	if not isfile(d["archive"]): error("パラメータが不正です: "+d["archive"])
	if py(): return None
	if cmd(): return None
	error("このファイルの内容を表示できません")

def cmd():
	t=bsdTar()
	if t:
		l=getData([t,"-tf",d["archive"]])
		if l:
			print(l)
			return True
	t=gnuTar()
	if t:
		l=getData([t,"-tf",d["archive"]])
		if l:
			print(l)
			return True
	return False

def py():
	t=detect(d["archive"])
	if t=="zip":
		z=zf.ZipFile(file=d["archive"],mode="r")
		nl=z.namelist()
		z.close()
		for n in nl: print(n)
		return True
	if t=="tar":
		t=tf.open(name=d["archive"],mode="r:*")
		nl=t.getnames()
		t.close()
		for n in nl: print(n)
		return True
	return False