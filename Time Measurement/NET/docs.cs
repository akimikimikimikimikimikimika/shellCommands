using System;

public class docs {

	public static void help() {
		Console.Write(lib.clean(@"

			 使い方:
			  measure-net [options] [command] [arg1] [arg2]…
			  measure-net -multiple [options] ""[command1]"" ""[command2]""…

			  [command] を実行し,最後にその所要時間を表示します

			  measure --version : バージョン表示
			  measure --help    : ヘルプを表示

			  オプション

			   -o,-out,-stdout [string]
			   -e,-err,-stderr [string]
			    標準出力,標準エラー出力の出力先を指定します。指定しなければ inherit になります。
			    • inherit
			     stdoutはstdoutに,stderrはstderrにそれぞれ出力します
			    • discard
			     出力しません
			    • [file path]
			     指定したファイルに書き出します (追記)

			   -r,-result [string]
			    実行結果の出力先を指定します。指定しなければ stderr になります。
			    • stdout,stderr
			    • [file path]
			     指定したファイルに書き出します (追記)

			   -m,-multiple [string?]
			    複数のコマンドを実行します。このオプションを指定するとシェル経由で実行されます。
			    例えば measure echo 1 のように指定していたのを

			     measure -multiple ""echo 1"" ""echo 2""

			    などと1つ1つのコマンドを1つの文字列として渡して実行します
			    引数に次のいずれかの値を指定することができます (指定しなければserial)
			    • none
			     単一のコマンドとして実行します (-mを指定しない場合と同じ)
			    • serial
			     指定した複数のコマンドをその順に実行していきます
			    • spawn,parallel
			     シェルの同時起動により並列実行します
			    • thread
			     スレッドを利用して並列実行します

			    ※ -m オプションについてはエディションによって機能が異なるので,それぞれにおいてヘルプを確認してください。

		"));
	}

	public static void version() {
		Console.Write(lib.clean(@"

			 measure v2.4
			 .NET エディション (measure-net)

		"));
	}

}