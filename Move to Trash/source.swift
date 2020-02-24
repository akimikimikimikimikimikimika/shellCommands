import Foundation

func help() {
		print("""

		使い方:

		 trash (option) [path1] [path2]...
		  [path1] [path2]... で示されたファイルをゴミ箱に移動させます
		  rm コマンドを使う代わりに trash を利用することで,不意に削除してしまったファイルもゴミ箱から復元することができます
		  もちろん, trash を使う場合は完全には削除されないので,完全に削除したい場合は通常の rm を使用してください

		 オプション
		  -q : ファイルが存在しないなどエラーがあってもメッセージを出力しません

		""")
}

func message(_ m:String) {
	print(m)
	exit(1)
}

let args = CommandLine.arguments
let fm = FileManager.default

if args.count>1 {
	if args[1]=="help"||args[1]=="-help"||args[1]=="--help" {
		help()
		exit(0)
	}
	var first = 1
	var silent = false
	var failed = false
	if args[1]=="-q"||args[1]=="--silent" {
		silent = true
		first += 1
	}
	for n in first..<args.count {
		let p = args[n]
		let u = URL(fileURLWithPath: p)
		if !fm.fileExists(atPath: p) {
			if !silent {message("指定されたファイルは存在しません: \(p)")}
			failed = true
		}
		else {
			do {try fm.trashItem(at: u,resultingItemURL: nil)}
			catch {
				if !silent {message("ゴミ箱への移動に失敗しました: \(p)")}
				failed = true
			}
		}
	}
	exit(failed ? 1 : 0)
}
else {
	help()
	exit(0)
}