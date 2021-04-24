using .lib

module analyze
	export argAnalyze
	import ..Data,..CMHelp,..CMVersion,..MMNone,..MMSerial,..MMSpawn,..MMThread,..eq,..exitWithError,..clean

	@enum Key AKNull AKStdout AKStderr AKResult AKMultiple
	function argAnalyze(d::Data)
		l=ARGS

		if length(l)==0 exitWithError("引数が不足しています") end
		if eq(l[1],"-h","help","-help","--help") d.mode=CMHelp end
		if eq(l[1],"-v","version","-version","--version") d.mode=CMVersion end

		key::Key=AKNull
		n::Int=0

		for a in l
			n+=1
			if a=="" continue end

			proceed::Bool=true
			if eq(a,"-m","-multiple")
				d.multiple=MMSerial
				key=AKMultiple
			elseif eq(a,"-o","-out","-stdout") key=AKStdout
			elseif eq(a,"-e","-err","-stderr") key=AKStderr
			elseif eq(a,"-r","-result") key=AKResult
			else proceed=false end
			if proceed continue end

			if startswith(a,"-")
				exitWithError("不正なオプションが指定されています")
			elseif key!=AKNull
				proceed=true
				if key==AKStdout d.out=a end
				if key==AKStderr d.err=a end
				if key==AKResult d.result=a end
				if key==AKMultiple
					if eq(a,"none") d.multiple=MMNone
					elseif eq(a,"serial") d.multiple=MMSerial
					elseif eq(a,"spawn","parallel") d.multiple=MMSpawn
					elseif eq(a,"thread") d.multiple=MMThread
					else proceed=false end
				end
				key=AKNull
			end
			if proceed continue end

			d.command=view(l,n:length(l))
			break
		end

		if length(d.command)==0 exitWithError("実行する内容が指定されていません") end
	end

end