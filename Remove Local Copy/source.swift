#! /usr/bin/env swift

import Foundation

let fm = FileManager.default
let args = CommandLine.arguments

let path = args[1]

let u = URL(fileURLWithPath: path)
if !fm.fileExists(atPath: path) {
    print("指定されたファイルは存在しません")
}
else if !fm.isUbiquitousItem(at: u) {
    print("これはiCloudのファイルではありません")
}
else {
    try fm.evictUbiquitousItem(at: u)
    print("ローカルコピーを削除しました")
}