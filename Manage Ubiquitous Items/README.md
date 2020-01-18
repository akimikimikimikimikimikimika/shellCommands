## Manage Ubiquitous Item

iCloudに保存されたファイルを操作します。<br>
このコマンドではiCloudファイルに対して次の操作をすることが可能です。
* iCloud上に保存されたファイルをダウンロードする (`download`)
* iCloudファイルのローカルコピーを削除する (`evict`)
* iCloudファイルのリンクを生成する (`url`)

### 使い方

```sh
mui [options] [file1] [file2]...
```

* `-d`,`-download`
```sh
mui -d ~/Documents/file1 ~/Documents/file2
```
この操作により,ファイル `file1` `file2` をダウンロードします。<br>
既にダウンロードしているファイルに対しては何もしません。

* `-e`,`-evict`
```sh
mui -e ~/Documents/file1 ~/Documents/file2
```
この操作により,ファイル `file1` `file2` のローカルコピーを削除できます。<br>
MacにダウンロードしたiCloudファイルを削除することで,Macの空き容量を増やせます。<br>
本来,使用頻度の低いファイルはmacOSが自動的にダウンロードを削除しますが,このコマンドを使うことで,手動で削除することができます。

* `-u`,`-url`
```sh
mui -u ~/Documents/file
```
この操作により,ファイル `file` のリンクを作成できます。<br>
作成したリンクは標準出力で出力されます。<br>
URLを受け取った者は,Web上からそのファイルをダウンロードできます。<br>
URL生成以降にファイルに加えた変更はダウンロードファイルには反映されません。 (リンクが作成された時点でファイルのスナップショットが撮られる)<br>
フラットファイルのみURLが生成可能です。 (バンドルファイルやディレクトリは不可)<br>
標準では,そのファイルを削除するまでURLは有効です。

### コンパイル

```sh
cd "Manage Ubiquitous Item"
make build
```