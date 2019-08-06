func help() {
	print("""


	使い方

	 random help
	  このページを表示します

	 random version
	  このソフトウェアのバージョンを表示します

	 random [options]
	  以下のオプションに基づき乱数を生成します

	  -i,-int [min] [max] : 整数の乱数を出力します
	    min,maxを指定すると, min≤x≤max の範囲内の値に絞ります
	    指定しない場合は,標準の範囲で出力します
	  -r,-real [min] [max] : 実数の乱数を出力します (初期値)
	    min,maxを指定すると, min≤x<max の範囲内の値に絞ります
	    指定しない場合は,0≤x<1の範囲の実数を出力します

	  -l,-length : 生成する乱数の数を指定 (初期値:1)

	  -parallel [type] : 並列処理により乱数を生成します
	    • Dispatch  : 並列処理にDispatchを使用
	    • Operation : 並列処理にOperationを使用

	  -Dispatch  : -parallel Dispatch と同じ
	  -Operation : -parallel Operation と同じ

	  -hidden : 生成した乱数を表示しません (ベンチマーク等に最適)


	""")
}

func version() {
	print("""

	Random (Swift version)
	ビルド: 2019/7/31

	Swift で書かれた乱数生成システムです。
	シェルから簡単に乱数を呼び出すことができます。

	""")
}