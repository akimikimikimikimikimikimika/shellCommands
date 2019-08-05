# shellCommands
主にmacOS向けの,ちょっとした便利なシェルコマンドの数々です。<br>
当リポジトリの bin ディレクトリ内にコンパイルした実行ファイルを配置して,パスを通すことで汎用性の高いコマンドの数々が利用できます。

## Manage Ubiquitous Items
`mui` コマンド<br>
iCloudに保存されたファイルに関して操作をします。

## Time Measurement
`measure` コマンド<br>
コマンドを実行するのにかかった所要時間を計測します。

## Time Stamp Reset
`resetTS` コマンド<br>
ファイルの変更日時をUnixエポックに変更します。

## MASReceipt Addition
`addMASReceipt` コマンド<br>
任意のアプリケーションに `_MASReceipt` を付加します。

## Cleanup
`cleanup` コマンド<br>
一部のMacで現れうる不要な隠しファイルをまとめて削除することができます。

## パスを通す
このリポジトリ内のディレクトリ bin のパスを通すことで,任意のシェルからこれらのコマンドを簡単に利用することができるようになります。