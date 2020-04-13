## Time Measurement

コマンドを実行するのにかかった所要時間を計測し,表示します。

### 使い方

```sh
measure [options] someCommand arg1 arg2...
```
この操作により, `someCommand` を実行し,その所要時間を表示します。<br>
`arg1 arg2...` はそのままコマンドに引数として渡されます。<br>
バージョン2より有効な `[options]` の指定により動作をカスタマイズできます。

### 計測可能域

このコマンドでは,マイクロ秒の次元から,時間の次元まで計測可能です。

### ソースコード

このプログラムは様々な言語のバージョンが存在します。<br>
それぞれ異なるコマンドが用意されているため,言語を指定して利用することもできます<br>
言語によってバージョンが異なるので注意してください。使える機能が異なります。<br>
`measure`と指定すると,Cのバイナリ (`measure-c`) が実行されます。

| コマンド | 言語 | バージョン |
|:-:|:-:|:-:|
| `measure` | C | 1.0 |
| `measure-c` | C | 1.0 |
| `measure-cpp` | C++ | 1.0 |
| `measure-go` | Go | 2.0 |
| `measure-swift` | Swift | 2.0 |
| `measure-rs` | Rust | 2.0 |
| `measure-py` | Python | 2.0 |
| `measure-js` | JavaScript | 2.0 |
| `measure-rb` | Ruby | 2.0 |
| `measure-php` | PHP | 2.0 |

### コンパイル

```sh
cd "Time Measurement"
make build-clang++ / make build-g++
make build-clang   / make build-gcc
make build-go
make build-rs
make build-swift
```