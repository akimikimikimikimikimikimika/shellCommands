import Foundation

typealias FH = FileHandle
let fm=FileManager.default

enum CommandMode {
	case main(data)
	case help
	case version
}
typealias CM = CommandMode

enum MultipleMode {
	case none
	case serial
	case spawn
	case operation
	case dispatch
}
typealias MM = MultipleMode

enum ChildOutput {
    case inherit
    case discard
    case file(String)
}
typealias CO = ChildOutput

enum ResultOutput {
    case stdout
    case stderr
    case file(String)
}
typealias RO = ResultOutput

struct data {
	var command:[String] = []
	var out:CO = .inherit
	var err:CO = .inherit
	var result:RO = .stderr
	var multiple:MM = .none
}



@discardableResult func exitWithError(_ text:String) -> Any {
	FH.standardError.write((text+"\n").data(using:.utf8) ?? Data())
	exit(1)
}

func clean(_ text:String) -> String {
	var t=text
	t=replace("^\\t+","",t)
	t=replace("\\n\\t+","\n",t)
	return t+"\n"
}

func replace(_ of:String,_ with:String,_ text:String) -> String {
	return text.replacingOccurrences(
		of:of,
		with:with,
		options:.regularExpression,
		range:text.range(of:text)
	)
}

func write(_ fh:FH,_ text:String) {
	fh.write(text.data(using:.utf8) ?? Data())
}

func makeArray<T>(_ size:Int) -> [T] {
	var l:[T] = []
	l.reserveCapacity(size)
	return l
}