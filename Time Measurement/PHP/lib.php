<?php

const CMMain   =0;
const CMHelp   =1;
const CMVersion=2;

const MMNone  =0;
const MMSerial=1;
const MMSpawn =2;

class data {
	public $mode=CMMain;
	public $command=[];
	public $out="inherit";
	public $err="inherit";
	public $result="stderr";
	public $multiple=MMNone;
}

function error($text) {
	fputs(STDERR,$text.PHP_EOL);
	exit(1);
}

function clean($text) {
	$text=preg_replace("/^\t+/m","",$text);
	return $text;
}

function eq($target,...$cans) {
	foreach ($cans as $c) if ($c==$target) return true;
	return false;
}