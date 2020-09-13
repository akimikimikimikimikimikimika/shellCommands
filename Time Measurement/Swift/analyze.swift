enum AnalyzeKey {
	case out
	case err
	case result
	case multiple
}
typealias AK = AnalyzeKey

func argAnalyze() -> CM {
	var l=CommandLine.arguments
	l.removeFirst()

	if l.count==0 { exitWithError("引数が不足しています") }
	else {
		switch l[0] {
			case "-h","help","-help","--help": return .help
			case "-v","version","-version","--version": return .version
			default: break
		}
	}

	var d=data()
	var key:AK? = nil
	var n = -1
	for a in l {
		n+=1
		if a.isEmpty { continue }

		var proceed=true
		switch a {
			case "-m","-multiple":
				d.multiple = .serial
				key = .multiple
			case "-o","-out","-stdout": key = .out
			case "-e","-err","-stderr": key = .err
			case "-r","-result": key = .result
			default: proceed=false
		}
		if proceed { continue }

		if a.hasPrefix("-") { exitWithError("不正なオプションが指定されています") }
		else if let k = key {
			proceed=true
			switch k {
				case .out: d.out = s2co(a)
				case .err: d.err = s2co(a)
				case .result: d.result = s2ro(a)
				case .multiple:
					switch a {
						case "none":
							d.multiple = .none
						case "serial","":
							d.multiple = .serial
						case "spawn","parallel":
							d.multiple = .spawn
						case "operation","thread":
							d.multiple = .operation
						case "dispatch":
							d.multiple = .dispatch
						default: proceed=false
					}
			}
			key=nil
		}
		if proceed { continue }

		d.command=Array(l[n...])
		break
	}

	if d.command.count==0 { exitWithError("実行する内容が指定されていません") }

	return .main(d)
}

func s2co(_ text:String) -> CO {
	switch text {
		case "inherit": return .inherit
		case "discard": return .discard
		default: return .file(text)
	}
}

func s2ro(_ text:String) -> RO {
	switch text {
		case "stdout": return .stdout
		case "stderr": return .stderr
		default: return .file(text)
	}
}