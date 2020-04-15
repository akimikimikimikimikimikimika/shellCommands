## Time Measurement

コマンドを実行するのにかかった所要時間を計測し,表示します。

### 使い方

```sh
measure [options] someCommand arg1 arg2...
```
この操作により, `someCommand` を実行し,その所要時間を表示します。<br>
`arg1 arg2...` はそのままコマンドに引数として渡されます。<br>
バージョン2より有効な `[options]` の指定により動作をカスタマイズできます。

### オプション

- `-o`,`-out`,`-stdout`
- `-e`,`-err`,`-stderr`<br>
	標準出力,標準エラー出力の出力先を指定します<br>
	指定しなければ `inherit` になります
    * `inherit`<br>
		stdoutはstdoutに,stderrはstderrにそれぞれ出力します
    * `discard`<br>
		出力しません
    * `[file path]`<br>
		指定したファイルに書き出します (追記)

- `-r`,`-result`<br>
	実行結果の出力先を指定します<br>
	指定しなければ `stderr` になります<br>
	- `stdout`,`stderr`
	- `[file path]`<br>
		指定したファイルに書き出します (追記)


- `-m`,`-multiple`<br>
    複数のコマンドを実行します<br>
	通常はシェル経由で実行されます<br>
    例えば `measure echo 1` と指定していたのを<br>
	```sh
	measure -multiple "echo 1" "echo 2"
	```
    などと1つ1つのコマンドを1つの文字列として渡して実行します

### 計測可能域

このコマンドでは,マイクロ秒の次元から,時間の次元まで計測可能です。

### ソースコード

このプログラムは様々な言語のバージョンが存在します。<br>
それぞれ異なるコマンドが用意されているため,言語を指定して利用することもできます<br>
言語によってバージョンが異なるので注意してください。使える機能が異なります。<br>
`measure`と指定すると,Cのバイナリ (`measure-c`) が実行されます。

| コマンド | 言語 | バージョン |
|:-:|:-:|:-:|
| `measure` | C | 2.0 |
| `measure-c` | C | 2.0 |
| `measure-cpp` | C++ | 2.0 |
| `measure-go` | Go | 2.0 |
| `measure-swift` | Swift | 2.0 |
| `measure-rs` | Rust | 2.0 |
| `measure-js` | JavaScript | 2.0 |
| `measure-py` | Python | 2.0 |
| `measure-rb` | Ruby | 2.0 |
| `measure-php` | PHP | 2.0 |
| `measure-java` | Java | 2.0 |

### コンパイル

```sh
cd "Time Measurement"
make build-clang   / make build-gcc
make build-clang++ / make build-g++
make build-go
make build-rs
make build-swift
```