## Appearance

macOSのアピアランスを変更します。

## 特徴

* システム環境設定から変更可能なアピアランスをコマンドラインから容易に変更可能。

### 使い方

- ライトモード/ダークモード
    * `appearance light`<br>
        ライトモードに変更します
    * `appearance dark`<br>
        ダークモードに変更します
- アクセント
    * `appearance blue`<br>
    * `appearance purple`<br>
    * `appearance pink`<br>
    * `appearance red`<br>
    * `appearance orange`<br>
    * `appearance yellow`<br>
    * `appearance green`<br>
    * `appearance graphite`<br>
        指定したアクセントカラーに変更します

### コンパイル

```sh
cd "Appearance"
clang *.c -o ../bin/appearance -std=c17 -O3
```