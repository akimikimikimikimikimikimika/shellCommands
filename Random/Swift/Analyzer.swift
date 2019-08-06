func argAnalyze(_ c:inout Customize) -> Bool {

	let args = CommandLine.arguments

	if args.count>1 {
		switch args[1] {
			case "help","-help","--help":
				help()
				return false
			case "version","-version","--version":
				version()
				return false
			default: break
		}
	}

	var sr = ("","")

	enum Responder {
		case none
		case length
		case concurrent
		case rangeFirst
		case rangeSecond
	}
	var r:Responder = .none
	for n in 1..<args.count {
		switch args[n] {
			case "-l","-length": r = .length
			case "-i","-int":
				c.valueType = .int
				r = .rangeFirst
			case "-r","-real":
				c.valueType = .real
				r = .rangeFirst
			case "-parallel","-concurrent":
				r = .concurrent
				fallthrough
			case "-dispatch":
				c.concurrent = .Dispatch
			case "-operation":
				c.concurrent = .Operation
			case "-hidden","-invisible":
				c.visible = false
			default:
			switch r {
				case .length:
					c.length=UInt(args[n]) ?? 1
					r = .none
				case .rangeFirst:
					sr.0 = args[n]
					c.defaultRange = false
					r = .rangeSecond
				case .rangeSecond:
					sr.1 = args[n]
					r = .none
				case .concurrent:
					switch args[n] {
						case "Dispatch": c.concurrent = .Dispatch
						case "Operation": c.concurrent = .Operation
						default: c.concurrent = .Dispatch
					}
					r = .none
				case .none: break
			}
		}
	}

	if sr.0 != "" {
		if c.valueType == .int {
			let ir = (Int(sr.0) ?? 0,Int(sr.1) ?? 0)
			if ir.0==ir.1 {c.intRange = ir.0...ir.0}
			else if ir.0<ir.1 {c.intRange = ir.0...ir.1}
			else if ir.0>ir.1 {c.intRange = ir.1...ir.0}
		}
		if c.valueType == .real {
			let rr = (Double(sr.0) ?? 0,Double(sr.1) ?? 0)
			if rr.0==rr.1 {
				exitByError("範囲指定に問題があります")
			}
			else if rr.0<rr.1 {c.realRange = rr.0..<rr.1}
			else if rr.0>rr.1 {c.realRange = rr.1..<rr.0}
		}
	}

	return true

}