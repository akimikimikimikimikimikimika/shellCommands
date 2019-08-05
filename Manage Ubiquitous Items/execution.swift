import Foundation

let fm = FileManager.default

func execution(_ d:data) {
	if d.action == .none {
		message("実行するアクションが指定されていません")
	}
	else if d.path.count==0 {
		message("ファイルが指定されていません")
	}
	else {for p in d.path {
		var u = URL(fileURLWithPath: p)
		var exist = true
		if !fm.fileExists(atPath: p) {
			let ip=replace(in: p,"([^/]+)$",".$1.icloud")
			if fm.fileExists(atPath: ip) {
				u = URL(fileURLWithPath: ip)
			}
			else {
				print("指定されたファイルは存在しません: \(p)")
				exist = false
			}
		}
		if exist {
			if !fm.isUbiquitousItem(at: u) {
				print("これはiCloudのファイルではありません: \(p)")
			}
			else {switch d.action {
				case .evict:
					do {try fm.evictUbiquitousItem(at: u)}
					catch {message("ローカルコピーの削除に失敗しました: \(p)")}
				case .download:
					do {try fm.startDownloadingUbiquitousItem(at: u)}
					catch {message("ダウンロードに失敗しました: \(p)")}
				case .url:
					do {
						let wu = try fm.url(forPublishingUbiquitousItemAt: u, expiration: nil)
						print(wu.absoluteString)
					}
					catch {message("リンクの生成に失敗しました: \(p)")}
				case .none: break
			}}
		}
	}}
}