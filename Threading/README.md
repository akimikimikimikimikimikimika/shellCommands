## Threading

複数のコマンドの実行を容易にします。

## 特徴

* 値の代入により,似通った複数のコマンドをシンプルにまとめられる。
* 簡単に並列実行を実現。並列実行する際の煩雑なコードは不要。

### 使い方

```sh
thread command1 command2...
```
この操作により, `command1`,`command2` を実行します。<br>
それぞれ,引数も含めて1つの文字列で表現する必要があります。<br>
詳細な使い方は `thread help` を参照してください。

### コンパイル

```sh
cd "Threading"
clang++ *.cpp -o ../bin/thread -std=c++2a -O3
```