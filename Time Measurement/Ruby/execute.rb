require_relative "./lib.rb"

class Execute

	@@d=nil
	@@o=nil
	@@e=nil
	@@r=nil

	@@res=""
	@@ec=0

	def self.main(rd)
		@@d=rd
		@@o=co2f @@d.out,:out
		@@e=co2f @@d.err,:err
		@@r=ro2f @@d.result

		case @@d.multiple
			when MM::NONE   then single
			when MM::SERIAL then serial
			when MM::SPAWN  then spawnProcess
			when MM::THREAD then thread
			when MM::FORK   then forkProcess
		end

		@@r.puts @@res
		close @@o
		close @@e
		close @@r
		exit @@ec
	end

	def self.single
		p=SP.new(@@d.command)

		st=Time.now
		p.run
		en=Time.now

		@@res=clean <<-"Result"
			time: #{descTime en-st}
			process id: #{p.pid}
			#{p.descEC}
		Result
		@@ec=p.ec
	end

	def self.serial
		pl=SP.multiple(@@d.command)
		lp=pl[pl.length-1]

		st=Time.now
		pl.each do |p|
			p.run
			if p.ec!=0 then
				lp=p
				break
			end
		end
		en=Time.now

		@@res="time: #{descTime en-st}\n"
		pl.each do |p|
			n=p.order
			@@res+="process#{n} id: #{p.pid<0 ? "N/A" : p.pid}\n"
		end
		@@res+=lp.descEC
		@@ec=lp.ec
	end

	def self.spawnProcess
		pl=SP.multiple(@@d.command)

		st=Time.now
		pl.each { |p| p.start }
		pl.each { |p| p.wait }
		en=Time.now

		SP.collect(pl,st,en)
	end

	def self.thread
		pl=SP.multiple(@@d.command)
		tf=Proc.new { |p| p.run }

		st=Time.now
		pl.map { |p| Thread.new(p,&tf) }.each { |t| t.join }
		en=Time.now

		SP.collect(pl,st,en)
	end

	def self.forkProcess
		pl=SP.multiple(@@d.command)

		st=Time.now
		pl.each { |p| p.start_fork }
		pl.each { |p| p.wait }
		en=Time.now

		SP.collect(pl,st,en)
	end

	class SP < self
		def initialize(args)
			@args=args
			@order=0
			@pid=-1
			@ec=0
		end
		def self.multiple(commands)
			n=1
			commands.map do |c|
				p=SP.new(c)
				p.order=n
				n+=1
				p
			end
		end
		def self.collect(pl,st,en)
			@@res="time: #{descTime en-st}\n"
			pl.each do |p|
				n=p.order
				@@res+="process#{n} id: #{p.pid}\n"
				@@res+=p.descEC+"\n"
				n+=1
				@@ec=p.ec if p.ec>@@ec
			end
		end

		def start
			@pid=spawn(*@args,:in=>:in,:out=>@@o,:err=>@@e)
		end
		def start_fork
			@pid=fork { exec(*@args,:in=>:in,:out=>@@o,:err=>@@e) }
		end
		def wait
			@status=Process.waitpid2(@pid)[1]
			@ec=@status.exitstatus
		end
		def run
			start
			wait
		end
		def descEC
			@status.signaled? ? "terminated due to signal #{@status.termsig}" : "exit code: #{@status.exitstatus}"
		end
		attr_accessor :order
		attr_reader :pid,:ec
	end



	def self.co2f(d,inherit)
		case d
			when "inherit" then inherit
			when "discard" then "/dev/null"
			else fh(d)
		end
	end

	def self.ro2f(d)
		case d
			when "stdout" then STDOUT
			when "stderr" then STDERR
			else fh(d)
		end
	end

	@opened={}
	def self.fh(path)
		return @opened[path] if @opened.has_key? path
		begin
			@opened[path]=File.open(path,"a")
		rescue
			error("指定したパスには書き込みできません: "+path)
		end
	end

	def self.close(fh)
		fh.close if fh.class==File
	end



	def self.descTime(sec)
		t=""
		r=sec/3600;v=r.floor
		t+="#{v}h " if v>=1
		r=(r-v)*60;v=r.floor
		t+="#{v}m " if v>=1
		r=(r-v)*60;v=r.floor
		t+="#{v}s " if v>=1
		r=(r-v)*1000
		t+="#{sprintf("%07.3f",r)}ms"
		t
	end

	def self.descEC(s)
		s.signaled? ? "terminated due to signal #{s.termsig}" : "exit code: #{s.exitstatus}"
	end

end