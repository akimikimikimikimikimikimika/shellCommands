## Time Measurement

コマンドを実行するのにかかった所要時間を計測し,表示します。

### 使い方

```sh
measure someCommand arg1 arg2...
```
この操作により, `someCommand` を実行し,その所要時間を表示します。<br>
`arg1 arg2...` はそのままコマンドに引数として渡されます。

### 計測可能域

このコマンドでは,マイクロ秒の次元から,時間の次元まで計測可能です。

### ソースコード

このプログラムはC,C++,Rubyの3つのバージョンが存在します。<br>
Rubyは簡易的にテストするために書かれており,確実性も高いと思われます。CやC++はコンパイルして利用するため,場合によっては高速に動作します。<br>
`measure`と指定すると,Cのバイナリが実行されます。バージョンを指定して実行する場合は,それぞれ`measure-c`,`measure-cpp`,`measure-ruby` と指定します。

### コンパイル

```sh
cd "Time Measurement"
make build-clang++ / make build-g++
make build-clang   / make build-gcc
clang++ *.cpp -o ../bin/measure-cpp -std=c++2a -O3
```