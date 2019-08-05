import Foundation

let args = CommandLine.arguments

func message(_ m:String) {
    print(m)
    exit(1)
}

struct data {
	var path:[String] = []
	var action:Action = .none
	enum Action {
		case none
		case download
		case evict
		case url
	}
	init(){}
}

if args.count>1 {
	if args[1]=="help"||args[1]=="-help"||args[1]=="--help" {
		help()
		exit(0)
	}
	var d=data()
	for n in 1..<args.count {
		switch args[n] {
			case "-d","-download": d.action = .download
			case "-e","-evict": d.action = .evict
			case "-u","-url": d.action = .url
			default: d.path.append(args[n])
		}
	}
	execution(d)
}
else {
	help()
	exit(0)
}