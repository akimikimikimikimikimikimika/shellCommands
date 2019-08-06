#include <stdio.h>
#include <stdlib.h>

void n() {
	printf("\n");
}

void help() {
	n();
	printf("使い方");n();
	printf(" random help");n();
	printf("  このページを表示します");n();
	n();
	printf(" random version");n();
	printf("  このソフトウェアのバージョンを表示します");n();
	n();
	printf(" random [options]");n();
	printf("  以下のオプションに基づき乱数を生成します");n();
	n();
	printf("  -s,-seed [string|int] : 乱数シードを指定します (初期値:time)");n();
	printf("    • none");n();
	printf("       シードを与えません");n();
	printf("       このオプションでは常に同じ乱数が生成される可能性があります");n();
	printf("    • time");n();
	printf("       現在時刻 (Unixエポック) に基づくシードを指定します");n();
	printf("    • [int]");n();
	printf("       0以上の整数をシードとして与えます");n();
	n();
	printf("  -l,-length [int] : 生成する乱数の数を指定します (初期値:1)");n();
	n();
	printf("  -i,-int [min] [max] : 整数の乱数を出力します");n();
	printf("    min,maxを指定すると, min≤x≤max の範囲内の値に絞ります");n();
	printf("    指定しない場合は,0≤x≤%dで出力します",RAND_MAX);n();
	printf("  -r,-real [min] [max] : 実数の乱数を出力します (初期値)");n();
	printf("    min,maxを指定すると, min≤x<max の範囲内の値に絞ります");n();
	printf("    指定しない場合は,0≤x<1の範囲の実数を出力します");n();
	n();
	printf("  -hidden : 生成した乱数を表示しません (ベンチマーク等に最適)");n();
	n();n();
}

void version() {
	n();
	printf("Random (C version)");n();
	printf("ビルド: 2019/7/31");n();n();
	printf("C で書かれた乱数生成システムです。");n();
	printf("シェルから簡単に乱数を呼び出すことができます。");n();
	n();
}