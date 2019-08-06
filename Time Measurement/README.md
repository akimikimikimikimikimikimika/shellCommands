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
Rubyは簡易的にテストするために書かれており,確実性も高いと思われます。CやC++はコンパイルして利用するため,場合によっては高速に動作します。

### コンパイル

```sh
cd "Time Measurement"
clang *.c -o ../bin/CMeasure -std=c17 -O3
clang++ *.cpp -o ../bin/CppMeasure -std=c++2a -O3
```