## Random

本格的な乱数をコマンドから容易に生成します。<br>
幾つかの言語のバージョンを用意しています。それぞれ生成アルゴリズムが異なるため,言語ごとに使い方が僅かに変わります。

### 使い方

```sh
random [options]
```
この操作により,乱数を生成します。<br>
`[options]` には乱数生成の方法などオプションを指定します。オプションの内容は `random help` で参照できます。

### ソースコード

このプログラムは Fortran,C,C++,Swift,Go,Rust の6つのバージョンが存在します。但し,前者2つは標準では時間シードで生成するため,利用には注意が必要です。<br>
`random`と指定すると,C++のバイナリが実行されます。バージョンを指定して実行する場合は,それぞれ `random-f`,`random-c`,`random-cpp`,`random-swift`,`random-go`,`random-rust` と指定します。

### コンパイル

```sh
cd "Random"
make build-fortran
make build-clang++ / make build-g++
make build-clang   / make build-gcc
make build-swift
make build-go
(cd Cargo ; cargo build --release)
```

### クレート

Rustのコードにおいては crates.io に登録されているRust標準の乱数生成クレートを利用しています。