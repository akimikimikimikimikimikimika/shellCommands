let {help}=require("./help.js");
let {Create}=require("./create.js");
let {Expand}=require("./expand.js");
let {Paths}=require("./paths.js");
let u=require("./util.js");
let process=require("process");

exports.core=()=>{
	let a=process.argv.slice(2);
	if (a.length==1) {
		if (a[0]=="help" || a[0]=="-help" || a[0]=="--help") help("");
		else u.error("引数が不足しています");
	}
	else if (a.length==0) u.error("引数が不足しています");
	else if (a[0]=="create" || a[0]=="compress") Create.main(a[0]);
	else if (a[0]=="expand" || a[0]=="extract" || a[0]=="decompress") Expand.main();
	else if (a[0]=="paths" || a[0]=="list") Paths.main();
	else if (a[0]=="help") help(a[1]);
	else u.error("コマンドが無効です: "+a[0]);
};