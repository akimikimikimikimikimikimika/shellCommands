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
	elsif l[0]=="-h" || l[0]=="help" || l[0]=="-help" || l[0]=="--help" then help
	elsif l[0]=="-v" || l[0]=="version" || l[0]=="-version" || l[0]=="--version" then version
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
			when "-stdout" then key=:stdout
			when "-stderr" then key=:stderr
			when "-result" then key=:result
			when "-multiple" then $multiple=true
			else
				noFlags=true
				$command.push a
		end
	end
	if $command.length==0 then error "実行する内容が指定されていません" end
end

class Execute

	def initialize
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
				if ec!=0 then break end
			end
			en=Time.now
			r.puts "time: "+(descTime en-st)
			pl.length.times { |n| r.puts "process#{n+1} id: "+pid[n].to_s }
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
		begin
			File.open(path,"a")
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
		if sec/3600>=1 then t+="#{(sec/3600).floor}h " end
		if sec/60>=1 then t+="#{(sec/60).floor%60}m " end
		if sec>=1 then t+="#{sec.floor%60}s " end
		t+="#{sprintf("%.3f",(sec*1000)%1000)}ms"
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

		   -out,-err
		    標準出力,標準エラー出力の出力先を指定します
		    指定しなければ inherit になります
		    • inherit
		     stdoutはstdoutに,stderrはstderrにそれぞれ出力します
		    • discard
		     出力しません
		    • [file path]
		     指定したファイルに書き出します (追記)

		   -result
		    標準出力,標準エラー出力,実行結果の出力先を指定します
		    指定しなければ stderr になります
		    • stdout,stderr
		    • [file path]
		     指定したファイルに書き出します (追記)

		   -multiple
		    複数のコマンドを実行します
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