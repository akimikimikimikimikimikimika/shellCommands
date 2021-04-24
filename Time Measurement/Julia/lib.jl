module lib
	export Data,eq,exitWithError,clean,CMMain,CMHelp,CMVersion,MMNone,MMSerial,MMSpawn,MMThread

	@enum CommandMode CMMain CMHelp CMVersion
	@enum MultipleMode MMNone MMSerial MMSpawn MMThread

	Base.@kwdef mutable struct Data
		command::Array{String,1}=[]
		out::String="inherit"
		err::String="inherit"
		result::String="stderr"
		multiple::MultipleMode=MMNone
		mode::CommandMode=CMMain
	end

	function eq(target,candidates...)
		for c in candidates
			if c==target return true end
		end
		return false
	end

	function exitWithError(message)
		println(stderr,message)
		exit(1)
	end

	function clean(text)
		text=replace(text,r"^\t+"m=>s"")
		return text
	end

end