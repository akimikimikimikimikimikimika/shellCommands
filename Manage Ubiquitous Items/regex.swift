import Foundation

func replace(in text:String,_ of:String,_ with:String) -> String {
	return text.replacingOccurrences(of: of, with: with, options: .regularExpression, range: text.range(of: text))
}