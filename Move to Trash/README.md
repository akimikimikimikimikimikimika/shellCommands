## Move to Trash

ファイルをゴミ箱に移動させます。

### 使い方

```sh
trash file1 file2...
```

`file1 file2...` をゴミ箱に移動させます。<br>
rm コマンドを使う代わりに trash を利用することで,不意に削除してしまったファイルもゴミ箱から復元することができます。
もちろん, trash を使う場合は完全には削除されないので,完全に削除したい場合は通常の rm を使用してください。

### コンパイル

```sh
cd "Move to Trash"
swiftc *.swift -o ../bin/trash
```