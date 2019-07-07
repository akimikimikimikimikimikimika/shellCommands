#! /usr/bin/env ruby

if ARGV.length==0 then
	puts "引数が不足しています"
elsif ARGV[0]=="help" then
 puts """
  使い方:
   measure [command]
   measure -nooutput [command]
	[command] を実行し,最後にその所用時間を表示します
	-nooutputオプションを付加すると,標準出力の内容を表示しません
 """
else
	if ARGV[0]=="-nooutput" then
		ARGV.shift
		command=ARGV.join(" ")
		st=Time.now
		`#{command}`
		en=Time.now
	else
		command=ARGV.join(" ")
		st=Time.now
		system(command)
		en=Time.now
	end
	diff=en-st
	if diff/3600>=1 then
		print "#{(diff/3600).floor}h "
	end
	if diff/60>=1 then
		print "#{(diff/60).floor%60}m "
	end
	if diff>=1 then
		print "#{diff.floor%60}s "
	end
	print "#{sprintf("%.3f",(diff*1000)%1000)}ms"

	puts ""
end