#! /usr/bin/env swift

import Foundation

let fm = FileManager.default
let args = CommandLine.arguments

if args.count>1 {
    let path = args[1]
    let u = URL(fileURLWithPath: path)
    if !fm.fileExists(atPath: path) {
        print("指定されたファイルは存在しません")
        exit(1)
    }
    else if !fm.isUbiquitousItem(at: u) {
        print("これはiCloudのファイルではありません")
        exit(1)
    }
    else {
        try fm.evictUbiquitousItem(at: u)
        print("ローカルコピーを削除しました")
        exit(0)
    }
}
else {
    print("削除するファイルが指定されていません")
    exit(1)
}