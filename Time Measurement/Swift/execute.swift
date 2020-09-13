import Foundation
import Dispatch

class execute {

	var d:data
	let i=FH.standardInput
	var o:FH!
	var e:FH!
	var r:FH!

	var res=""
	var ec:Int32=0

	@discardableResult init(_ rd:data) {

		d=rd
		o=co2fh(d.out,FH.standardOutput)
		e=co2fh(d.err,FH.standardError)
		r=ro2fh(d.result)

		switch d.multiple {
			case .none:      single()
			case .serial:    serial()
			case .spawn:     spawn()
			case .operation: operation()
			case .dispatch:  dispatch()
		}

		write(r,res)
		exit(ec)
	}

	private func single() {
		let p=SP(self,"/usr/bin/env",d.command)

		let st=Date()
		p.run()
		let en=Date()

		res=clean("""
			time: \(descTime(st:st,en:en))
			process id: \(p.pid!)
			\(p.descEC())
		""")+"\n"

		ec=p.ec
	}

	private func serial() {
		let pl=SP.multiple(self,d.command)
		var lp=pl.last!

		let st=Date()
		for p in pl {
			p.run()
			if p.ec != 0 {
				lp=p
				break
			}
		}
		let en=Date()

		res+="time: \(descTime(st:st,en:en))\n"
		for p in pl { res+="process\(p.order) id: \(p.pid?.description ?? "N/A")\n" }
		res+="\(lp.descEC())\n"

		ec=lp.ec
	}

	private func spawn() {
		let pl=SP.multiple(self,d.command)

		let st=Date()
		for p in pl { p.start() }
		for p in pl { p.wait() }
		let en=Date()

		SP.collect(self,pl,st,en)
	}

	private func operation() {
		let pl=SP.multiple(self,d.command)
		let oq=OperationQueue()
		oq.isSuspended=true
		pl.forEach { p in
			oq.addOperation { p.run() }
		}

		let st=Date()
		oq.isSuspended=false
		oq.waitUntilAllOperationsAreFinished()
		let en=Date()

		SP.collect(self,pl,st,en)
	}

	private func dispatch() {
		let pl=SP.multiple(self,d.command)
		let dg=DispatchGroup()
		let dq=DispatchQueue(label:"measure",qos:.userInitiated,attributes:.concurrent)
		dq.suspend()
		pl.forEach { p in
			dq.async(group:dg) { p.run() }
		}

		let st=Date()
		dq.resume()
		dg.wait()
		let en=Date()

		SP.collect(self,pl,st,en)
	}

	private class SP {

		var x:execute

		private var p:Process
		private var started:Bool = false

		var order:Int=0
        var pid:Int32? {
			return started ? p.processIdentifier : nil
		}
		var ec:Int32 {
			if !started || p.isRunning { return 0 }
			switch (p.terminationReason) {
				case .exit: return p.terminationStatus
				case .uncaughtSignal: return 1
				@unknown default: return 0
			}
		}

		public init(_ exec:execute,_ cmd:String,_ args:[String]) {
			self.x=exec
			self.p=Process()
			p.executableURL=URL(fileURLWithPath:cmd)
			p.arguments=args
			p.standardInput=x.i
			p.standardOutput=x.o
			p.standardError=x.e
		}
		static func multiple(_ x:execute,_ commands:[String]) -> [SP] {
			let sh=ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/sh"
			var l:[SP]=[]
			l.reserveCapacity(commands.count)
			var n=1
			for c in commands {
				let p=SP(x,sh,["-c",c])
				p.order=n
				n+=1
				l.append(p)
			}
			return l
		}
		static func collect(_ x:execute,_ pl:[SP],_ st:Date,_ en:Date) {
			x.res+="time: \(x.descTime(st:st,en:en))\n"
			for p in pl {
				x.res+="process\(p.order) id: \(p.pid!)\n"
				x.res+=p.descEC()+"\n"
				if p.ec>x.ec { x.ec=p.ec }
			}
		}

		public func start() {
			do{
				try p.run()
				started=true
			}
			catch{ exitWithError("実行に失敗しました") }
		}
		public func wait() {
			p.waitUntilExit()
		}
		public func run() {
			start()
			wait()
		}
		public func descEC() -> String {
			if !started || p.isRunning { return "not exited" }
			switch (p.terminationReason) {
				case .exit: return "exit code: \(p.terminationStatus)"
				case .uncaughtSignal: return "terminated due to signal"
				@unknown default: return "unknown"
			}
		}

	}



	private func co2fh(_ c:CO,_ inherit:FH) -> FH {
		switch c {
			case .inherit: return inherit
			case .discard: return FH.nullDevice
			case let .file(f): return fh(f)
		}
	}

	private func ro2fh(_ r:RO) -> FH {
		switch r {
			case .stdout: return FH.standardOutput
			case .stderr: return FH.standardError
			case let .file(f): return fh(f)
		}
	}

	private var opened:[String:FH] = [:]
	private func fh(_ path:String) -> FH {
		if let f=opened[path] { return f }
		var v=true
		if !fm.fileExists(atPath:path) {
			v=fm.createFile(atPath:path,contents:nil,attributes:nil)
		}
		if v {
			if let f=FH(forWritingAtPath:path) {
				opened[path]=f
				do {
					try f.seekToEnd()
					return f
				} catch {}
			}
		}
		return exitWithError("指定したパスには書き込みできません: \(path)") as! FH
	}



	private func descTime(st:Date,en:Date) -> String {
		var t=""
		var r=DateInterval(start:st,end:en).duration
		// hours
		r/=3600
		var v=floor(r)
		if v>=1 { t+=d2s("%.0fh ",v) }
		// minutes
		r=(r-v)*60
		v=floor(r)
		if v>=1 { t+=d2s("%.0fm ",v) }
		// seconds
		r=(r-v)*60
		v=floor(r)
		if v>=1 { t+=d2s("%.0fs ",v) }
		// milliseconds
		r=(r-v)*1000
		t+=d2s("%07.3fms",r)
		return t
	}

	private func d2s(_ f:NSString,_ v:Double) -> String {
		return NSString(format:f,v) as String
	}

}