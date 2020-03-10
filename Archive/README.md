## Archive

幾つかのアーカイブフォーマット/圧縮フォーマットが簡単に取り扱えます。<br>
元来それぞれのフォーマットには取り扱うためのコマンドが用意され,コマンドの扱い方はバラバラであった。この `Archive` コマンドは対応する全てのフォーマットで同じ引数•スイッチで利用できるようになって,扱いやすくなっています。<br>
利用するコンピュータで引数•スイッチに応じて最適なコマンドを見つけ実行しやすくしています<br>

### 使い方

### 基本
```sh
arc [コマンド] [オプション]
arc help # 全般的な使い方の説明
arc help [コマンド] # それぞれのコマンドのオプションの説明
```

#### アーカイブの生成
```sh
arc create [archive path] [input file paths]... [options]
arc compress [input file paths]... [options]
```
`[input file paths]...` で指定したファイルを含むzipアーカイブを `[archive path]` に作成します。その他の形式はオプションで指定可能
`[archive path]` の代わりに `-o [path]`, `[input file path]` の代わりに `-i [path1] [path2]...` でも指定可能。<br>
以後のコマンドも含め,入力ファイルのパスは `-i` で,出力ファイルのパスは `-o` でスペース区切りで指定できるようになっている。

#### アーカイブの内容を表示
```sh
arc paths [archive path]
arc list [archive path]
```
`[archive path]` で指定したアーカイブに含まれるファイルの一覧を表示します。

#### アーカイブの展開
```sh
arc expand [archive path] [options]
arc decompress [archive path] [options]
arc extract [archive path] [options]
```
`[archive path]` をアーカイブと同じディレクトリに展開します。オプションで幾つかの細かい設定もできます

### ソースコード

このプログラムは幾つかの言語のバージョンが存在している<br>
それぞれ異なるコマンド名を持ち, `arc` の箇所を適宜次のように置き換えて使用する。

* `arc-py` (Python 3)
* `arc-rb` (Ruby)
* `arc-php` (PHP)
* `arc-js` (Node.js)
* `arc-java` (Java)

尚, `arc` はデフォルトで `arc-java` のシンボリックリンクである