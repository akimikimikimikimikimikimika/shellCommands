#! /usr/bin/env swift

import Foundation

func main() {
	argAnalyze()
	execute()
}

func argAnalyze() {
	var l=CommandLine.arguments
	l.removeFirst()
	if l.count==0 { exitWithError("引数が不足しています") }
	else {
		switch l[0] {
			case "-h","help","-help","--help": help()
			case "-v","version","-version","--version": version()
			default: break
		}
	}
	var n=0
	var key:AK? = nil
	for a in l {
		if let k = key {
			switch k {
				case .stdout: out = CO.s2co(a)
				case .stderr: err = CO.s2co(a)
				case .result: result = RO.s2ro(a)
			}
			key=nil
			continue
		}
		var body=false
		switch a {
			case "-o","-out","-stdout": key = .stdout
			case "-e","-err","-stderr": key = .stderr
			case "-r","-result": key = .result
			case "-m","-multiple": multiple = true
			default: body=true
		}
		if body {
			command=Array(l[n...])
			break
		}
		n+=1
	}
	if command.count==0 { exitWithError("実行する内容が指定されていません") }
}

class execute {

	// main function
	@discardableResult init() {

		let i=FH.standardInput
		let o=out.co2fh(.stdout)
		let e=err.co2fh(.stderr)
		let r=result.ro2fh

		var ec:Int32?=0 // exit code
		var res="" // result text

		// make process
		let mp:(String,[String])->Process = { cmd,args in
			let p=Process()
			p.executableURL=URL(fileURLWithPath:cmd)
			p.arguments=args
			p.standardInput=i
			p.standardOutput=o
			p.standardError=e
			return p
		};

		if multiple {
			let pl:[Process] = command.map { c in mp(shell(),["-c",c]) }
			let st=Date()
			for p in pl {
				run(p,&ec)
				if ec != 0 { break }
			}
			let en=Date()
			res+="time: \(descTime(st:st,en:en))\n"
			for n in 0..<pl.count {
				let pid=pl[n].processIdentifier
				res+="process\(n+1) id: \(pid==0 ? "N/A" : pid.description)\n"
			}
			res+="\(descEC(ec))\n"
		}
		else {
			let p=mp("/usr/bin/env",command)
			let st=Date()
			run(p,&ec)
			let en=Date()
			res=clean("""
				time: \(descTime(st:st,en:en))
				process id: \(p.processIdentifier)
				\(descEC(ec))
			""")+"\n"
		}

		write(r,res)
		exit(ec ?? 255)

	}

	private func shell() -> String {
		return ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/sh"
	}

	private func run(_ p:Process,_ ec:inout Int32?) {
		do{
			try p.run()
			p.waitUntilExit()
			ec = p.terminationReason == .exit ? p.terminationStatus : nil
		}
		catch{ exitWithError("実行に失敗しました") }
	}

	private func descEC(_ ec:Int32?)->String {
		if let c=ec { return "exit code: \(c)" }
		else { return "terminated due to signal" }
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

func help() {
	write(FH.standardOutput,clean("""

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

	"""))
	exit(0)
}

func version() {
	write(FH.standardOutput,clean("""

		 measure v2.2
		 Swift バージョン (measure-swift)

	"""))
	exit(0)
}

@discardableResult func exitWithError(_ text:String) -> Any {
	FH.standardError.write((text+"\n").data(using:.utf8) ?? Data())
	exit(1)
}

func clean(_ text:String) -> String {
	var t=text
	t=replace("^\\t+","",t)
	t=replace("\\n\\t+","\n",t)
	return t
}

func replace(_ of:String,_ with:String,_ text:String)->String {
	return text.replacingOccurrences(of:of,with:with,options:.regularExpression,range:text.range(of:text))
}

func write(_ fh:FH,_ text:String) {
	fh.write(text.data(using:.utf8) ?? Data())
}



typealias FH = FileHandle
class Util {
	enum ChildOutput {
		case inherit
		case discard
		case file(String)
		static func s2co(_ text:String) -> ChildOutput {
			switch text {
				case "inherit": return .inherit
				case "discard": return .discard
				default: return .file(text)
			}
		}
		func co2fh(_ t:Util.ResultOutput) -> FH {
			switch self {
				case .inherit:
					switch t {
						case .stdout: return FH.standardOutput
						case .stderr: return FH.standardError
						default: return exitWithError("unknown error") as! FH
					}
				case .discard: return FH.nullDevice
				case let .file(f): return Util.fh(f)
			}
		}
	}
	enum ResultOutput {
		case stdout
		case stderr
		case file(String)
		static func s2ro(_ text:String) -> ResultOutput {
			switch text {
				case "stdout": return .stdout
				case "stderr": return .stderr
				default: return .file(text)
			}
		}
		var ro2fh:FH {
			switch self {
				case .stdout: return FH.standardOutput
				case .stderr: return FH.standardError
				case let .file(f): return Util.fh(f)
			}
		}
	}
	enum AnalyzeKey {
		case stdout
		case stderr
		case result
	}
	private static let fm=FileManager.default
	private static var opened:[String:FH] = [:]
	private static func fh(_ path:String) -> FH {
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
}
typealias CO = Util.ChildOutput
typealias RO = Util.ResultOutput
typealias AK = Util.AnalyzeKey

var command:[String] = []
var out:CO = .inherit
var err:CO = .inherit
var result:RO = .stderr
var multiple:Bool = false

main()