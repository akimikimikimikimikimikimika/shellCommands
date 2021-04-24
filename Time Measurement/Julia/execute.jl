using .lib

module execute
	export exec
	import ..Data,..clean,..exitWithError,..MMNone,..MMSerial,..MMSpawn,..MMThread
	using Printf,Base.Threads

	d=nothing
	o=nothing
	e=nothing
	r=nothing

	ec=0
	res=""

	function exec(rd::Data)
		global d,o,e,r
		d=rd
		o=co2f(d.out,stdout)
		e=co2f(d.err,stderr)
		r=ro2f(d.result)

		if d.multiple==MMNone single()
		elseif d.multiple==MMSerial serial()
		elseif d.multiple==MMSpawn spawn()
		elseif d.multiple==MMThread thread()
		end

		print(r,res)
		close(o)
		close(e)
		close(r)
		exit(ec)
	end

	function single()
		global res

		p=SP(`$(d.command)`,join(d.command," "))

		sec=@elapsed begin
			runSP(p)
		end

		res=clean("""
			time: $(descTime(sec))
			process id: $(p.pid)
			$(descEC(p))
		""")
		ec=p.ec
	end

	function serial()
		global res

		pl=multiple()
		lp=pl[length(pl)]

		sec=@elapsed begin
			for p in pl
				runSP(p)
				if p.ec!=0
					lp=p
					break
				end
			end
		end

		res=join([
			"time: $(descTime(sec))",
			map(p->"process$(p.order) id: $(p.pid<0 ? "N/A" : p.pid)",pl)...,
			descEC(lp),""
		],"\n")
		ec=lp.ec
	end

	function spawn()
		pl=multiple()

		sec=@elapsed begin
			for p in pl startSP(p) end
			for p in pl waitSP(p) end
		end

		collect(pl,sec)
	end

	function thread()
		pl=multiple()

		sec=@elapsed begin
			@threads for p in pl
				runSP(p)
			end
		end

		collect(pl,sec)
	end

	Base.@kwdef mutable struct SP
		cmd::Base.CmdRedirect
		description::String
		process=nothing
		order::Int = 0
		pid::Int32 = -1
		ec::Int = 0
		SP(cmdObj,desc) = new(pipeline(cmdObj,stdout=stdout,stderr=stderr,stdin=stdin),desc)
	end
	function startSP(p::SP)
		try
			p.process=run(p.cmd,wait=false)
			pid=getpid(p.process)
			p.pid=pid
		catch e
			exitWithError("実行に失敗しました: $(p.description)")
		end
	end
	function waitSP(p::SP)
		wait(p.process)
		p.ec=p.process.exitcode
	end
	function runSP(p::SP)
		startSP(p)
		waitSP(p)
	end
	function descEC(p::SP)::String
		return @sprintf("exit code: %.d",p.ec)
	end
	function multiple()::Array{SP,1}
		pl=fill(-1,length(d.command))
		n=1
		l::Array{SP,1}=[]
		for c in d.command
			if occursin(r"#\{\}\(\)\[\]<>\|\&\*\?~;",c)
				sh=get(ENV,"SHELL","sh")
				p=SP(`$sh -c $c`)
			else
				s=c
				s=replace(s,"\\"=>"\\\\")
				s=replace(s,"`"=>"\\`")
				s=replace(s,"\$"=>"\\\$")
				try
					p=SP(eval(Meta.parse("`$s`")),d.command)
				catch e
					exitWithError("パースに失敗しました: $c")
				end
			end
			p.order=n
			n+=1
			append!(l,[p])
		end
		return l
	end
	function collect(pl::Array{SP,1},sec)
		global res,ec

		res=join(Iterators.flatten([
			["time $(descTime(sec))"],
			map(function (p)
			if p.ec>ec ec=p.ec end
				return ["process$(p.order) id: $(p.pid)",descEC(p)]
			end,pl)...,[""]
		]),"\n")
	end

	function co2f(d,i)
		if d=="inherit" return i
		elseif d=="discard" return devnull
		else return fh(d)
		end
	end

	function ro2f(d)
		if d=="stdout" return stdout
		elseif d=="stderr" return stderr
		else return fh(d)
		end
	end

	opened=Dict()
	function fh(path)
		if haskey(opened,path) return opened[path]
		else
			try
				io=open(path,"a")
				opened[path]=io
				return io
			catch e
				exitWithError("指定したパスには書き込みできません: "+path)
			end
		end
	end

	function descTime(sec)::String
		t=""
		r=sec/3600
		v=floor(r)
		if v>=1 t*=@sprintf("%.0fh ",v) end
		r=(r-v)*60
		v=floor(r)
		if v>=1 t*=@sprintf("%.0fm ",v) end
		r=(r-v)*60
		v=floor(r)
		if v>=1 t*=@sprintf("%.0fs ",v) end
		r=(r-v)*1000
		t*=@sprintf("%07.3fms",r)
		return t
	end

end