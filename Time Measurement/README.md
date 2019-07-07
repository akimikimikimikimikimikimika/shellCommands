## Time Measurement

コマンドを実行するのにかかった所要時間を計測し,表示します。

### 使い方

```sh
measure someCommand arg1 arg2...
measure -nooutput someCommand arg1 arg2...
```
この操作により, `someCommand` を実行し,その所要時間を表示します。<br>
`arg1 arg2...` はそのままコマンドに引数として渡されます。<br>
`-nooutput` を指定した場合,コマンドの標準出力を出力しません。

### 計測可能域

このコマンドでは,マイクロ秒の次元から,時間の次元まで計測可能です。