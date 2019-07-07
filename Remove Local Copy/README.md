## Remove Local Copy

iCloudに保存されたファイルのローカルコピーを削除します。<br>
MacにダウンロードしたiCloudファイルを削除することで,Macのストレージを増やすことに貢献します。<br>
使用頻度の低いファイルはmacOSで自動的にダウンロードが削除されますが,このコマンドを使うことで,手動で削除することができます。

### 使い方

```sh
rmlc foo
```
この操作により,ファイル `foo` のローカルコピーを削除できます。<br>
`foo` がiCloudファイルでない場合,エラーが返されます。

### ビルド

```sh
(cd "Remove Local Copy" ; swiftc source.swift -o bin)
rm -r rmlc
ln -s "Remove Local Copy/bin" rmlc
```
Swiftで書かれたソースコードを上に示したシェルコマンドでコンパイルできます。