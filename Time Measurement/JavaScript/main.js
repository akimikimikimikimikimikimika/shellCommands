#! /usr/bin/env node

const
{data,CMMain,CMHelp,CMVersion}=require("./lib.js"),
{argAnalyze}=require("./analyze.js"),
execute=require("./execute.js").main,
{help,version}=require("./docs.js");

let d=new data();

argAnalyze(d);

switch (d.mode) {
	case CMMain:    execute(d); break;
	case CMHelp:    help();     break;
	case CMVersion: version();  break;
}