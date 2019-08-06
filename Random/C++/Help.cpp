#include <iostream>
#include <random>

using namespace std;

void help() {
	cout << endl << endl;
	cout << "使い方" << endl << endl;
	cout << " random help" << endl;
	cout << "  このページを表示します" << endl;
	cout << endl;
	cout << " random version" << endl;
	cout << "  このソフトウェアのバージョンを表示します" << endl;
	cout << endl;
	cout << " random [options]" << endl;
	cout << "  以下のオプションに基づき乱数を生成します" << endl;
	cout << endl;
	cout << "  -m,-mode [string] : 乱数生成方法を指定 (初期値:device)" << endl;
	cout << "    [string] には以下の値が指定できます" << endl;
	cout << "    • rand : C言語由来の通常の乱数生成器を使用" << endl;
	cout << "       このデバイスでの取り得る値の範囲は次の通り: 0~" << RAND_MAX << endl;
	cout << "    • device : 予測不能な乱数生成器で乱数を生成" << endl;
	cout << "       コンピュータのハードウェア的ノイズなどから乱数が生成されます" << endl;
	cout << "       -sのシードは無視されます" << endl;
	cout << "       このデバイスでの取り得る値の範囲は次の通り: " << random_device::min() << "~" << random_device::max() << endl;
	cout << "    • default : 標準的な方法に基づく擬似乱数を生成" << endl;
	cout << "       このモードは,非専門的な利用の場合に適しています" << endl;
	cout << "       以下に示すモードのうちいづれかを利用します" << endl;
	cout << "    • minstd0 : 最小標準法による擬似乱数を生成 (オリジナル版)" << endl;
	cout << "    • minstd : 最小標準法による擬似乱数を生成" << endl;
	cout << "    • knuth : 最小標準法+並び替えによる擬似乱数を生成" << endl;
	cout << "    • ranlux3 : RANLUX法による擬似乱数を生成 (贅沢さレベル3)" << endl;
	cout << "    • ranlux4 : RANLUX法による擬似乱数を生成 (贅沢さレベル4)" << endl;
	cout << "    • mt : メルセンヌツイスター法による擬似乱数を生成 (32bit)" << endl;
	cout << "    • mt64 : メルセンヌツイスター法による擬似乱数を生成 (64bit)" << endl;
	cout << endl;
	cout << "  -s,-seed [string|int] : 乱数シードを指定します (初期値:device)" << endl;
	cout << "    -m device 以外の場合に指定可能です" << endl;
	cout << "    • none" << endl;
	cout << "       シードを与えません" << endl;
	cout << "       このオプションでは常に同じ乱数が生成される可能性があります" << endl;
	cout << "    • device" << endl;
	cout << "       予測不能な乱数をシードとして指定します" << endl;
	cout << "       -m device で得られる乱数をシードとして利用します" << endl;
	cout << "    • time" << endl;
	cout << "       現在時刻 (Unixエポック) に基づくシードを指定します" << endl;
	cout << "    • [int]" << endl;
	cout << "       0以上の整数をシードとして与えます" << endl;
	cout << endl;
	cout << "  -l,-length [int] : 生成する乱数の数を指定します (初期値:1)" << endl << endl;
	cout << endl;
	cout << "  -d,-discard [int] : 擬似乱数において指定した数だけ状態を進めます (初期値:0)" << endl;
	cout << "   -m rand,device 以外の場合に指定可能です" << endl;
	cout << endl;
	cout << "  -i,-int [min] [max] : 整数の乱数を出力します" << endl;
	cout << "    min,maxを指定すると, min≤x≤max の範囲内の値に絞ります" << endl;
	cout << "    指定しない場合は,指定された乱数モード特有の範囲で出力します" << endl;
	cout << "  -r,-real [min] [max] : 実数の乱数を出力します (初期値)" << endl;
	cout << "    min,maxを指定すると, min≤x<max の範囲内の値に絞ります" << endl;
	cout << "    指定しない場合は,0≤x<1の範囲の実数を出力します" << endl;
	cout << endl;
	cout << "  -parallel : 並列処理により乱数を生成します" << endl;
	cout << "  -hidden : 生成した乱数を表示しません (ベンチマーク等に最適)" << endl;
	cout << endl << endl;
}

void version() {
	cout << endl;
	cout << "Random (C++ version)" << endl;
	cout << "ビルド: 2019/7/31" << endl << endl;
	cout << "C++ で書かれた乱数生成システムです。" << endl;
	cout << "シェルから簡単に乱数を呼び出すことができます。" << endl;
	cout << endl;
}