include("lib.jl")
include("analyze.jl")
include("execute.jl")
include("docs.jl")

using .lib
using .analyze
using .execute
using .docs

d=Data()

argAnalyze(d)

if d.mode == CMMain
	exec(d)
elseif d.mode == CMHelp
	help()
elseif d.mode == CMVersion
	version()
end