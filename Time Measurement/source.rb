#! /usr/bin/env ruby

$command=[]
$out="inherit"
$err="inherit"
$result="stderr"
$multiple=false

def main
	argAnalyze
	Execute.new()
end

def argAnalyze
	l=ARGV
	if l.length==0 then error "引数が不足しています"
	else
		case l[0]
			when "-h","help","-help","--help" then help()
			when "-v","version","-version","--version" then version()
		end
	end
	noFlags=false
	key=nil
	l.each do |a|
		if noFlags
			$command.push a
			next
		end
		if key
			case key
				when :stdout then $out=a
				when :stderr then $err=a
				when :result then $result=a
			end
			key=nil
			next
		end
		case a
			when "-o","-out","-stdout" then key=:stdout
			when "-e","-err","-stderr" then key=:stderr
			when "-r","-result" then key=:result
			when "-m","-multiple" then $multiple=true
			else
				noFlags=true
				$command.push a
		end
	end
	error "実行する内容が指定されていません" if $command.length==0
end

class Execute

	def initialize
		@opened=Hash.new
		o=co2f $out,:out
		e=co2f $err,:err
		r=ro2f $result
		ec=0
		if $multiple
			pl=[]
			st=Time.now
			$command.each do |c|
				pid,ec=run(c,o,e)
				pl.push pid
				break if ec!=0
			end
			en=Time.now
			r.puts "time: "+(descTime en-st)
			pl.length.times { |n| r.puts "process#{n+1} id: "+pl[n].to_s }
			r.puts "exit code: "+ec.to_s
		else
			st=Time.now
			pid,ec=run($command,o,e)
			en=Time.now
			r.puts clean <<-"Result"
				time: #{descTime en-st}
				process id: #{pid}
				exit code: #{ec}
			Result
		end
		r.close
		exit ec
	end

	def co2f(d,inherit)
		case d
			when "inherit" then inherit
			when "discard" then "/dev/null"
			else fh(d)
		end
	end

	def ro2f(d)
		case d
			when "stdout" then STDOUT
			when "stderr" then STDERR
			else fh(d)
		end
	end

	def fh(path)
		return @opened[path] if @opened.has_key? path
		begin
			@opened[path]=File.open(path,"a")
		rescue
			error("指定したパスには書き込みできません: "+path)
		end
	end

	def run(c,o,e)
		system(*c,:in=>:in,:out=>o,:err=>e)
		s=$?
		return s.pid,s.exitstatus
	end

	def descTime(sec)
		t=""
		r=sec/3600;v=r.floor
		t+="#{v}h " if v>=1
		r=(r-v)*60;v=r.floor
		t+="#{v}m " if v>=1
		r=(r-v)*60;v=r.floor
		t+="#{v}s " if v>=1
		r=(r-v)*1000
		t+="#{sprintf("%.3f",r)}ms"
		t
	end

	private :co2f,:fh,:descTime

end

def error(text)
	STDERR.puts text
	exit 1
end

def help
	print clean <<-"Help"

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

	Help
	exit
end

def version
	print clean <<-"Version"

		 measure v2.0
		 Ruby バージョン (measure-rb)

	Version
	exit
end

def clean(text)
	text.gsub(/\n\t+/,"\n").sub(/^\t+/,"").sub(/\n\z/,"")
end

main