module CommandMode
	MAIN   =0
	HELP   =1
	VERSION=2
end
CM=CommandMode

module MultipleMode
	NONE  =0
	SERIAL=1
	SPAWN =2
	THREAD=3
	FORK  =4
end
MM=MultipleMode

class DataStore
	def initialize
		@mode=CM::MAIN
		@command=[]
		@out="inherit"
		@err="inherit"
		@result="stderr"
		@multiple=MM::NONE
	end
	attr_accessor :mode,:command,:out,:err,:result,:multiple
end

def error(text)
	STDERR.puts text
	exit 1
end

def clean(text)
	text.gsub(/^\t+/,"")
end