import sys
import os
import shutil
import subprocess
import tempfile
import glob
import getpass
import math
import re
import zipfile
import tarfile

id=os.getpid()
cwd=os.getcwd()
env=os.environ.copy()
chdir=os.chdir
mv=shutil.move
cp=shutil.copy
rm=os.remove
fileList=os.listdir
concatPath=os.path.join
which=shutil.which
isfile=os.path.isfile
isdir=os.path.isdir
islink=os.path.islink
mkdir=os.makedirs
basename=os.path.basename
hardlink=os.link
def getdir(path): return os.path.dirname(os.path.abspath(path))
def writable(path): return os.access(path,os.W_OK)

zf=zipfile
tf=tarfile

class temp():
	__tmp=None
	tmpDir=None
	def __init__(self):
		self.__tmp=tempfile.TemporaryDirectory()
		self.tmpDir=self.__tmp.name
	def blank(self):
		io=open(concatPath(self.tmpDir,".blank"),"w")
		io.close()
	def done(self): self.__tmp.cleanup()

def disableCache(): sys.dont_write_bytecode = True

def password():
	p=""
	while p=="": p=getpass.getpass("パスワード: ")
	return p

def error(text):
	sys.stderr.write(text+os.linesep)
	exit(1)

def detect(path):
	if zf.is_zipfile(path): return "zip"
	if tf.is_tarfile(path): return "tar"
	else: return None

def exec(cmd):
	p=subprocess.Popen(cmd,stdin=None,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL,env=env)
	p.wait()
	return p.returncode

def getData(cmd):
	p=subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.DEVNULL,env=env)
	p.wait()
	if p.returncode==0: return p.stdout.read().decode("utf8").rstrip()
	else: return None

def bsdTar():
	l=[which("bsdtar"),which("tar")]
	for t in l:
		if t!=None:
			v=getData([t,"--version"])
			if re.search(r"bsdtar",v)!=None: return t
	return None

def gnuTar():
	l=[which("gnutar"),which("tar"),which("gtar")]
	for t in l:
		if t!=None:
			v=getData([t,"--version"])
			if re.search(r"GNU tar",v)!=None: return t
	return None

def helpText(text):
	text=re.sub(r"\n\t+",r"\n",text)
	text=re.sub(r"^\r?\n","",text)
	text=re.sub(r"\r?\n\r?\n$","",text)
	print(text)

def levelCast(val):
	if re.search(r"^[1-9]$",val): l=(val,str(math.ceil(int(val)/2)*2-1),val,val)
	elif re.search(r"^1[0-9]$",val):
		l=("9","9",val,val)
		if int(val)>12: l[2]="12"
	elif val=="default": l=("6","5","1","3")
	else: l=("6","5","1","3")
	return l

class CompressType:
	def __init__(self,data):
		self.keys=data[0]
		self.compressCmd=data[2]
		self.decompressCmd=data[4]
		self.tarExt=data[1]
		self.ext=data[3]
	@classmethod
	def each(cls,l):
		return [CompressType(a) for a in l]

compressors=CompressType.each([
	[["z","Z","compress","lzw"],"tar.Z",["compress","-f"],"Z",["uncompress","-f"]],
	[["gz","gzip","deflate"],"tgz",["gzip","-f","-k"],"gz",["gzip","-d","-f"]],
	[["bz","bz2","bzip","bzip2"],"tbz2",["bzip2","-z","-f","-k"],"bz2",["bzip2","-d"]],
	[["xz","lzma"],"txz",["xz","-z","-f","-k","-T0"],"xz",["xz","-d","-f"]],
	[["lz","lzip"],"tlz",["lzip","-f","-k"],"lz",["lzip","-d","-f"]],
	[["lzo","lzop"],"tar.lzo",["lzop","-f"],"lzo",["lzop","-d","-f"]],
	[["br","brotli"],"tar.br",["brotli","-f"],"br",["brotli","-d","-f"]],
	[["zst","zstd","zstandard"],"tar.zst",["zstd","-f","-T0"],"zst",["zstd","-d","-f","-T0"]],
	[["lz4"],"tar.lz4",["lz4","-f"],"lz4",["lz4","-d","-f"]]
])

def switches(d,params,inputs,max=0):

	args=sys.argv

	var=None
	multiple=False
	sharp=None
	step=1

	noSwitches=False

	for a in args[2:]:

		match=False

		if a=="--": noSwitches=match=True

		if not noSwitches:

			for cmd in params:
				for p in cmd[0]:
					if p=="-#":
						s=re.search(r"^\-([0-9]+)$",a)
						if s!=None:
							match=True
							sharp=s.group(1)
					elif p==a: match=True
					if match: break
				if match:
					var=None
					for act in cmd[1:]:
						if act[0]=="var":
							var=act[1]
							multiple=len(act)==3
						if act[0]=="write":
							if sharp!=None:
								d[act[1]]=sharp
								sharp=None
							else: d[act[1]]=act[2]
					break

			if not match:
				if re.search(r"^\-+",a)!=None: error("このスイッチは無効です: "+a)

			if not match:
				if var!=None:
					if multiple: d[var].append(a)
					else:
						d[var]=a
						var=None
					match=True

		if not match:
			if max>0 and step>max: error("パラメータが多すぎます")
			i=min([step,len(inputs)])-1
			if isinstance(d[inputs[i]],list): d[inputs[i]].append(a)
			else: d[inputs[i]]=a
			step+=1