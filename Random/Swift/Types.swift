enum ValueType {
	case int
	case real
}

enum ConcurrentType {
	case serial
	case Dispatch
	case DispatchSerial
	case Operation
}

struct Customize {
    var length:UInt = 1
    var valueType:ValueType = .real
    var concurrent:ConcurrentType = .serial
    var visible = true
    var intRange:ClosedRange<Int> = 0...1
    var realRange:Range<Double> = 0..<1
    var defaultRange = true
    var exec:(() -> Void)?
}