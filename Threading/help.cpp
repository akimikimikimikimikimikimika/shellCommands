#include <iostream>

using namespace std;

void exitWithError(string text) {
	cerr << text << endl;
	exit(1);
}

void help() {

	cout << endl;
	cout << "使い方:" << endl << endl;
	cout << " thread (command1) (command2)... [options]" << endl;
	cout << "   command1,command2... を実行します" << endl;
	cout << "   それぞれの実行内容は1つの文字列で表現する必要があります" << endl << endl;
	cout << " thread help" << endl;
	cout << "   このコマンドのヘルプを表示します" << endl << endl;
	cout << " プレースホルダ" << endl << endl;
	cout << "  以下の例で示すように, (command1) (command2)... のテキスト内にプレースホルダを指定することができます。" << endl;
	cout << "  プレースホルダは {} で指定でき,-sや-lのオプションを指定した順に代入します。" << endl;
	cout << "  {1} や {2} などとプレースホルダに番号を指定すると,その番号の順に現れた-sや-lを代入します。" << endl;
	cout << "  (command1) (command2)... はまとめて1つのグループを形成し,-sや-lオプションで指定した値ごとに異なる複数のグループが形成されます。" << endl;
	cout << "  -testオプションで代入済みのコマンドを確認することができます (ここではコマンドは実行されません)" << endl << endl;
	cout << " 例" << endl << endl;
	cout << "  thread \"traceroute example1.com\" \"traceroute example2.com\"" << endl;
	cout << "    example1.com,example2.comへのtracerouteを同時に実行します" << endl << endl;
	cout << "  thread \"traceroute {}\" -l example1.com example2.com" << endl;
	cout << "    example1.com,example2.comへのtracerouteを同時に実行します" << endl << endl;
	cout << "  thread \"traceroute example{}.com\" -s 1 3" << endl;
	cout << "    example1.com,example2.com,example3.comへのtracerouteを同時に実行します" << endl << endl;
	cout << "  thread \"traceroute www{}.example{}.com\" -s 1 2 -l A B" << endl;
	cout << "  thread \"traceroute www{1}.example{2}.com\" -s 1 2 -l A B" << endl;
	cout << "    www1.exampleA.com,www2.exampleA.com,www1.exampleB.com,www2.exampleB.comへのtracerouteを同時に実行します" << endl << endl;
	cout << "  thread \"traceroute www1.example{}.com\" \"traceroute www2.example{}.com\" -l A B" << endl;
	cout << "    www1.exampleA.com,www2.exampleA.com,www1.exampleB.com,www2.exampleB.comへのtracerouteを同時に実行します" << endl;
	cout << "    この場合,www1.exampleA.com,www2.exampleA.comで1グループ,www1.exampleB.com,www2.exampleB.comで1グループになります" << endl << endl;
	cout << endl;
	cout << " オプション一覧" << endl << endl;
	cout << "  -l (value1) (value2)..." << endl;
	cout << "   value1,value2... をプレースホルダ {} にそれぞれ代入します" << endl;
	cout << "   value1,value2... ごとに異なるグループが形成されます" << endl << endl;
	cout << "  -s (min) (max)" << endl;
	cout << "   min≤x≤max の範囲の整数をプレースホルダ {} にそれぞれ代入します" << endl;
	cout << "   min,max は整数で指定します" << endl;
	cout << "   異なる整数ごとに異なるグループが形成されます" << endl << endl;
	cout << "  -m (mode)" << endl;
	cout << "   コマンドの実行モードを指定します" << endl;
	cout << "   初期値は serial です" << endl;
	cout << "   (mode)には次の値が指定できます" << endl << endl;
	cout << "   serial" << endl;
	cout << "    全てのコマンドを直列実行します" << endl;
	cout << "    グループ毎に,グループ内での実行順序も, command1,command2... の指定した順に実行されます" << endl;
	cout << "    -serial でも指定可能です" << endl << endl;
	cout << "   group" << endl;
	cout << "    グループ単位で並列実行します" << endl;
	cout << "    グループ内での実行順序は, command1,command2... の指定した順に実行され,全てのグループが同時に処理を開始します" << endl;
	cout << "    -group でも指定可能です" << endl << endl;
	cout << "   parallel" << endl;
	cout << "    全てのコマンドを並列実行します" << endl;
	cout << "    グループの枠組みを超え,グループ内の全てのコマンドが同時に実行を開始します";
	cout << "    実行順序が守られないことがあるので,実行順序が重要なコマンドでは使用できません" << endl;
	cout << "    -parallel でも指定可能です" << endl << endl;
	cout << "  -test" << endl;
	cout << "   コマンドは実行されず,実行する予定のコマンドの表示のみを行います" << endl;
	cout << "   これにより,代入が適切であるか,並列実行されているかなどを確認することができます" << endl;
	cout << endl;

}