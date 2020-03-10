let u=require("./util.js");

let d={
    "archive":null
};

class Paths {

	static help() {
	    u.helpText(`

			arc paths [archive path] [options]
			arc list [archive path] [options]

			アーカイブに含まれるファイルの一覧を表示します

			オプション

			[archive path]
			-a [string],-i [string],--archive [string],--in [string]
			 アーカイブファイルを指定します

		`);
	};

	static main(){

		u.switches(d,[
			[["-a","-i","--archive","--in"],["var","archive"]]
		],["archive"],1);

		if (d["archive"]==null) u.error("アーカイブが指定されていません");
		if (!u.isfile(d["archive"])) u.error("パラメータが不正です: "+d["archive"]);
		if (cmd()) return null;
		u.error("このファイルの内容を表示できません");

	};

}
exports.Paths=Paths;

function cmd() {
    var t;
    t=u.bsdTar();
	if (t) {
		let l=u.getData([t,"-tf",d["archive"]]);
		if (l) {
			console.log(l);
			return true;
		}
	}
	t=gnuTar();
	if (t) {
		let l=getData([t,"-tf",d["archive"]]);
		if (l) {
			console.log(l);
			return true;
		}
	}
	return false;
}