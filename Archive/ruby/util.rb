require "tmpdir"

id=$$
$cwd=Dir.pwd
$env=ENV

=begin
	chdir(path) → Dir.chdir(path)
	mv(src,dst) → FileUtils.mv(src,dst)
	cp(src,dst) → FileUtils.cp(src,dst)
	rm(path) → FileUtils.rm_rf(path)
	mkdir(path) → FileUtils.mkdir_p(path)
	basename(path) → File.basename(path)
	hardlink(src,dst) → File.link(src,dst)
	writeable(path) → File.writable?(path)
=end

def fileList(path)
	Dir.entries(path).filter! {|v| v!="."&&v!=".."}
end
def which(cmd)
	r=getData(["which",cmd])
	return r if r!=nil && r!=""
	r=getData(["where",cmd])
	return r if r!=nil && r!=""
	nil
end
def isfile(path)
	return false if !File.exist?(path)
	File.ftype(path)=="file"
end
def isdir(path)
	return false if !File.exist?(path)
	File.ftype(path)=="directory"
end
def islink(path)
	return false if !File.exist?(path)
	File.ftype(path)=="link"
end
def getdir(path) File.dirname(File.expand_path(path)) end
def concatPath(*path)
	File.join(*path)
end

class Temp
	@tmpDir=nil
	attr_reader:tmpDir
	def initialize()
		@tmpDir=Dir.mktmpdir
	end
	def blank()
		io=File.open(concatPath(@tmpDir,".blank"),"w")
		io.close
	end
	def done()
		FileUtils.remove_entry_secure(@tmpDir)
	end
end

def password()
	if which("read")!=nil
		p=""
		while p=="" do
			p=`read -s -p "パスワード: " text ; echo>&2 ; echo $text`.rstrip()
		end
		p
	else
		error("パスワードが指定できません")
	end
end

def error(text)
	STDERR.puts(text)
	exit(1)
end

def exec(cmd,quiet=false)
	if quiet
		d={in:STDIN,out:"/dev/null",err:"/dev/null"}
	else
		d={in:STDIN,out:STDOUT,err:"/dev/null"}
	end
	pid=spawn($env,*cmd,d)
	Process.waitpid(pid)
	$?
end

def getData(cmd)
	begin
		r,w=IO.pipe
		pid=spawn($env,*cmd,{in:STDIN,out:w,err:"/dev/null"})
		Process.waitpid(pid)
		w.close()
		if $?==0
			t=r.read()
			r.close()
			t.rstrip()
		else
			nil
		end
	rescue
		nil
	end
end

def bsdTar()
	l=[which("bsdtar"),which("tar")]
	l.each do |t|
		if t!=nil
			v=getData([t,"--version"])
			if v =~ /bsdtar/
				return t
			end
		end
	end
	nil
end

def gnuTar()
	l=[which("gnutar"),which("tar"),which("gtar")]
	l.each do |t|
		if t!=nil
			v=getData([t,"--version"])
			if v =~ /GNU tar/
				return t
			end
		end
	end
	nil
end

def helpText(text)
	text=text.gsub(/\n\t+/,"\n").sub(/\r?\n\z/,"").sub(/\A\r?\n/,"")
	puts(text)
end

def levelCast(val)
	if val =~ /^[1-9]$/
		l=[val,((val.to_f/2).ceil*2-1).to_s,val,val]
	elsif val =~ /^1[0-9]$/
		l=["9","9",val,val]
		l[2]="12" if val.to_i>12
	elsif val=="default"
		l=["6","5","1","3"]
	else
		l=["6","5","1","3"]
	end
	l
end

class CompressType
	@keys=[]
	@compressCmd=[]
	@decompressCmd=[]
	@tarExt=[]
	@ext=[]
	attr_accessor :keys,:compressCmd,:decompressCmd,:tarExt,:ext
	def initialize(data)
		self.keys=data[0]
		self.compressCmd=data[2]
		self.decompressCmd=data[4]
		self.tarExt=data[1]
		self.ext=data[3]
	end
	def self.each(l)
		l.map { |a| CompressType.new(a) }
	end
end

$compressors=CompressType.each([
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

def switches(d,params,inputs,max=0)

	args=ARGV

	var=nil
	multiple=false
	sharp=nil
	step=1

	noSwitches=false

	args.shift
	args.each do |a|

		match=false

		noSwitches=match=true if a=="--"
		match=true if a==""

		if !noSwitches

			params.each do |cmd|
				cmd[0].each do |p|
					if p=="-#"
						s=a.scan(/^\-([0-9]+)$/)
						if s.length>0
							match=true
							sharp=s[0][0]
						end
					elsif p==a
						match=true
					end
					break if match
				end
				if match
					var=nil
					c=cmd.clone
					c.delete(0)
					c.each do |act|
						if act[0]=="var"
							var=act[1]
							multiple=act.length==3
						elsif act[0]=="write"
							if sharp!=nil
								d[act[1]]=sharp
								sharp=nil
							else
								d[act[1]]=act[2]
							end
						end
					end
					break
				end
			end

			if !match
				if a =~ /^\-+/
					error("このスイッチは無効です: "+a)
				end
			end

			if !match
				if var!=nil
					if multiple
						d[var].push(a)
					else
						d[var]=a
						var=nil
					end
					match=true
				end
			end

		end

		if !match
			error("パラメータが多すぎます") if max>0 && step>max
			i=[step,inputs.length].min-1
			if d[inputs[i]].is_a?(Array)
				d[inputs[i]].push(a)
			else
				d[inputs[i]]=a
			end
			step+=1
		end

	end
end