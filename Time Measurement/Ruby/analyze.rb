require_relative "./lib.rb"

def argAnalyze(d)
	l=ARGV

	if l.length==0 then error "引数が不足しています"
	else
		case l[0]
			when "-h","help","-help","--help" then
				d.mode=CM::HELP
				return
			when "-v","version","-version","--version" then
				d.mode=CM::VERSION
				return
		end
	end

	key=nil
	n=-1
	l.each do |a|
		n+=1
		if a.empty? then next end

		proceed=true
		case a
			when "-m","-multiple"
				d.multiple=MM::SERIAL
				key=:multiple
			when "-o","-out","-stdout"
				key=:stdout
			when "-e","-err","-stderr"
				key=:stderr
			when "-r","-result"
				key=:result
			else proceed=false
		end
		if proceed then next end

		if a.start_with?("-")
			error "不正なオプションが指定されています"
		elsif key
			proceed=true
			case key
				when :stdout   then d.out=a
				when :stderr   then d.err=a
				when :result   then d.result=a
				when :multiple then
					case a
						when "none"
							d.multiple=MM::NONE
						when "serial",""
							d.multiple=MM::SERIAL
						when "spawn","parallel"
							d.multiple=MM::SPAWN
						when "thread"
							d.multiple=MM::THREAD
						when "fork"
							d.multiple=MM::FORK
						else proceed=false
					end
			end
			key=nil
		end
		if proceed then next end

		d.command=l[n...l.length]
		break
	end

	error "実行する内容が指定されていません" if d.command.length==0
end