#! /usr/bin/env julia

command=[]
out="inherit"
err="inherit"
result="stderr"
multiple=false

function main()
	argAnalyze()
	execute.exec()
end

function eq(target,cans...)
	for c in cans
		if c==target return true end
	end
	return false
end

function help()
	print(clean("""

		 使い方:
		  measure [options] [command] [arg1] [arg2]…
		  measure -multiple [options] "[command1]" "[command2]"…

		  [command] を実行し,最後にその所要時間を表示します

		  オプション

		   -o,-out,-stdout
		   -e,-err,-stderr
		    標準出力,標準エラー出力の出力先を指定します
		    指定しなければ inherit になります
		    • inherit
		     stdoutはstdoutに,stderrはstderrにそれぞれ出力します
		    • discard
		     出力しません
		    • [file path]
		     指定したファイルに書き出します (追記)

		   -r,-result
		    実行結果の出力先を指定します
		    指定しなければ stderr になります
		    • stdout,stderr
		    • [file path]
		     指定したファイルに書き出します (追記)

		   -m,-multiple
		    複数のコマンドを実行します
		    通常はシェル経由で実行されます
		    例えば measure echo 1 と指定していたのを

		     measure -multiple "echo 1" "echo 2"

		    などと1つ1つのコマンドを1つの文字列として渡して実行します

	"""))
	exit(0)
end

function version()
	print(clean("""

		 measure v2.2
		 Julia バージョン (measure-jl)

	"""))
	exit(0)
end

function exitWithError(message)
	println(stderr,message)
	exit(1)
end

function clean(text)
	text=replace(text,r"^\t+"m=>s"")
	return text
end

@enum Key AKNull AKStdout AKStderr AKResult
function argAnalyze()
	global command,out,err,result,multiple
	l=ARGS
	if length(l)==0 exitWithError("引数が不足しています") end
	if eq(l[1],"-h","help","-help","--help") help() end
	if eq(l[1],"-v","version","-version","--version") version() end
	noFlags=false
	key=AKNull
	for n in 1:length(l)
		a=l[n]
		if key!=AKNull
			if key==AKStdout out=a end
			if key==AKStderr err=a end
			if key==AKResult result=a end
			key=AKNull
		elseif eq(a,"-o","-out","-stdout") key=AKStdout
		elseif eq(a,"-e","-err","-stderr") key=AKStderr
		elseif eq(a,"-r","-result") key=AKResult
		elseif eq(a,"-m","-multiple") multiple=true
		else
			command=view(l,n:length(l))
			break
		end
	end
	if length(command)==0 exitWithError("実行する内容が指定されていません") end
end

module execute
	export exec
	import ..command,..out,..err,..result,..multiple,..clean,..exitWithError
	using Printf

	function exec()
		o=co2f(out,stdout)
		e=co2f(err,stderr)
		r=ro2f(result)
		ec=0
		sec=0
		if multiple
			pl=fill(-1,length(command))
			cl=map(function(s)
				cmd=nothing
				if occursin(r"#\{\}\(\)\[\]<>\|\&\*\?~;",s)
					sh=get(ENV,"SHELL","sh")
					cmd=`$sh -c $s`
				else
					t=s
					t=replace(t,"\\"=>"\\\\")
					t=replace(t,"`"=>"\\`")
					t=replace(t,"\$"=>"\\\$")
					try
						cmd=eval(Meta.parse("`$s`"))
					catch e
						exitWithError("パースに失敗しました: $s")
					end
				end
				return pipeline(cmd,stdout=o,stderr=e,stdin=stdin)
			end,command)
			try
				sec=@elapsed begin
					for n in 1:length(cl)
						p=run(cl[n],wait=false)
						pl[n]=getpid(p)
						wait(p)
						ec=p.exitcode
						if ec!=0 break end
					end
				end
			catch e
				exitWithError("実行に失敗しました")
			end
			println(r,"time: $(descTime(sec))")
			for n in 1:length(pl)
				println(r,"process$n id: $(pl[n]<0 ? "N/A" : pl[n])")
			end
			println(r,"exit code: $(ec)")
		else
			cmd=pipeline(`$command`,stdout=o,stderr=e,stdin=stdin)
			pid=nothing
			try
				sec=@elapsed begin
					p=run(cmd,wait=false)
					pid=getpid(p)
					wait(p)
					ec=p.exitcode
				end
			catch e
				exitWithError("実行に失敗しました")
			end
			print(r,clean("""
				time: $(descTime(sec))
				process id: $pid
				exit code: $ec
			"""))
		end
		exit(ec)
	end

	function shell()
		if haskey(ENV,"SHELL") return ENV["SHELL"] end
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

	function descTime(sec)
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
using .execute

main()