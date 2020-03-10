<?php

require_once("help.php");
require_once("create.php");
require_once("expand.php");
require_once("paths.php");
require_once("util.php");

function core() {
	global $argv;
	$a=array_slice($argv,1);
	if (count($a)==1) {
		if ($a[0]=="help" || $a[0]=="-help" || $a[0]=="--help") Help::main("");
		else error("引数が不足しています");
	}
	else if (count($a)==0) error("引数が不足しています");
	else if ($a[0]=="create" || $a[0]=="compress") Create::main($a[0]);
	else if ($a[0]=="expand" || $a[0]=="extract" || $a[0]=="decompress") Expand::main();
	else if ($a[0]=="paths" || $a[0]=="list") Paths::main();
	else if ($a[0]=="help") Help::main($a[1]);
	else error("コマンドが無効です: ".$a[0]);
}

?>