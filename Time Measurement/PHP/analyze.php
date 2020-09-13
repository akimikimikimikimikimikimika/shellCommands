<?php

require_once("lib.php");

const Out=1;
const Err=2;
const Result=3;
const Multiple=4;

function argAnalyze($d) {
	global $argv;
	$l=$argv;
	array_shift($l);

	if (count($l)==0) error("引数が不足しています");
	else switch ($l[0]) {
		case "-h": case "help": case "-help": case "--help":
			$d->mode=CMHelp; return;
		case "-v": case "version": case "-version": case "--version":
			$d->mode=CMVersion; return;
	}

	$key=null;$n=-1;
	foreach ($l as $a) {
		$n++;
		if ($a=="") continue;

		$proceed=true;
		switch ($a) {
			case "-m": case "-multiple":
				$d->multiple=MMSerial;
				$key=Multiple; break;
			case "-o": case "-out": case "-stdout":
				$key=Out; break;
			case "-e": case "-err": case "-stderr":
				$key=Err; break;
			case "-r": case "-result":
				$key=Result; break;
			default: $proceed=false;
		}
		if ($proceed) continue;

		if ($a[0]=="-") error("不正なオプションが指定されています");
		else if ($key) {
			$proceed=true;
			switch ($key) {
				case Out:    $d->out   =$a; break;
				case Err:    $d->err   =$a; break;
				case Result: $d->result=$a; break;
				case Multiple:
					switch ($a) {
						case "none":
							$d->multiple=MMNone; break;
						case "serial": case "":
							$d->multiple=MMSerial; break;
						case "spawn": case "parallel":
							$d->multiple=MMSpawn; break;
						default: $proceed=false;
					}
			}
			$key=null;
		}
		if ($proceed) continue;

		$d->command=array_slice($l,$n);
		break;
	}

	if (count($d->command)==0) error("実行する内容が指定されていません");
}