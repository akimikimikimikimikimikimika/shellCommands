require_relative "help.rb"
require_relative "create.rb"
require_relative "expand.rb"
require_relative "paths.rb"
require_relative "util.rb"

def core()
	a=ARGV
	if a.length==1
		if a[0]=="help" || a[0]=="-help" || a[0]=="--help"
			Help::main("")
		else
			error("引数が不足しています")
		end
	elsif a.length==0
		error("引数が不足しています")
	elsif a[0]=="create" || a[0]=="compress"
		Create::main(a[0])
	elsif a[0]=="expand" ||a[0]=="extract" || a[0]=="decompress"
		Expand::main()
	elsif a[0]=="paths" || a[0]=="list"
		Paths::main()
	elsif a[0]=="help"
		Help::main(a[1])
	else
		error("コマンドが無効です: "+a[0])
	end
end