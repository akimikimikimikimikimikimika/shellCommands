import Foundation

func help() {
		print("""

		使い方:

		 trash [path1] [path2]...
		  [path1] [path2]... で示されたファイルをゴミ箱に移動させます
		  rm コマンドを使う代わりに trash を利用することで,不意に削除してしまったファイルもゴミ箱から復元することができます
		  もちろん, trash を使う場合は完全には削除されないので,完全に削除したい場合は通常の rm を使用してください

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
	for n in 1..<args.count {
		let p = args[n]
		let u = URL(fileURLWithPath: p)
		if !fm.fileExists(atPath: p) {
			message("指定されたファイルは存在しません: \(p)")
		}
		else {
			do {try fm.trashItem(at: u,resultingItemURL: nil)}
			catch {message("ゴミ箱への移動に失敗しました: \(p)")}
		}
	}
}
else {
	help()
	exit(0)
}