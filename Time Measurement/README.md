## Time Measurement

コマンドを実行するのにかかった所要時間を計測し,表示します。

### 使い方

```sh
measure [options] someCommand arg1 arg2...
```
この操作により, `someCommand` を実行し,その所要時間を表示します。  
`arg1 arg2...` はそのままコマンドに引数として渡されます。  
`[options]` の指定により動作をカスタマイズできます。

### オプション

- `-o`,`-out`,`-stdout` `[string]`
- `-e`,`-err`,`-stderr` `[string]`  
	標準出力,標準エラー出力の出力先を指定します  
	指定しなければ `inherit` になります
	* `inherit`  
		stdoutはstdoutに,stderrはstderrにそれぞれ出力します
	* `discard`  
		出力しません
	* `[file path]`  
		指定したファイルに書き出します (追記)

- `-r`,`-result` `[string]`  
	実行結果の出力先を指定します  
	指定しなければ `stderr` になります  
	- `stdout`,`stderr`
	- `[file path]`  
		指定したファイルに書き出します (追記)


- `-m`,`-multiple`  
	複数のコマンドを実行します  
	通常はシェル経由で実行されます  
	例えば `measure echo 1` と指定していたのを  
	```sh
	measure -multiple "echo 1" "echo 2"
	```
	などと1つ1つのコマンドを1つの文字列として渡して実行します
	引数に次のいずれかの値を指定することができます (指定しなければserial)
	* `none`  
		単一のコマンドとして実行します (-mを指定しない場合と同じ)
	* `serial`  
		指定した複数のコマンドをその順に実行していきます
	* `parallel`  
		並列実行します

	`-m` オプションに関してはコマンドによって多少差異があるので,詳しくは `measure help` を確認してください。

### 計測可能域

このコマンドでは,マイクロ秒の次元から,時間の次元まで計測可能です。

<br>

### ソースコード

このプログラムは様々な言語のエディションが存在します。  
それぞれ異なるコマンドが用意されているため,言語を指定して利用することもできます。  
言語によってバージョンが異なるので注意してください。使える機能が異なります。  
コマンド `measure` は標準でCのバイナリ (`measure-c`) へのリンクになっている。

| コマンド | 言語 | バージョン |
|:--|:-:|:-:|
| `measure-c` | C | 2.4 |
| `measure-cpp` | C++ | 2.4 |
| `measure-rs` | Rust | 2.4 |
| `measure-go` | Go | 2.4 |
| `measure-swift` | Swift | 2.4 |
| `measure-js` | JavaScript | 2.4 |
| `measure-py` | Python | 2.4 |
| `measure-jl` | Julia | 2.4 |
| `measure-php` | PHP | 2.4 |
| `measure-rb` | Ruby | 2.4 |
| `measure-java` | Java | 2.4 |
| `measure-ps` | PowerShell | 2.4 |
| `measure-cs` | C# | 2.4 |
| `measure-net` | .NET | 2.4 |

<br>

### コンパイル

```sh
cd "Time Measurement"
make build-c / make build-c-macos
make build-cpp / make build-cpp-macos
make build-go / make build-go-macos
make build-rust / make build-rust-macos
make build-swift / make build-swift-macos
make build-java
make build-cs
make build-net
```