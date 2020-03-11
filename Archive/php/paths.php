<?php

require_once("util.php");

class Paths {

	private static $d=[
		"archive"=>null
	];

	public static function help() {
		helpText(<<< Help

			arc paths [archive path] [options]
			arc list [archive path] [options]

			アーカイブに含まれるファイルの一覧を表示します

			オプション

			[archive path]
			-a [string],-i [string],--archive [string],--in [string]
			 アーカイブファイルを指定します

		Help);
	}

	public static function main() {
		$d=&static::$d;

		switches($d,[
			[["-a","-i","--archive","--in"],["var","archive"]]
		],["archive"],1);

		if ($d["archive"]==null) error("アーカイブが指定されていません");
		if (!is_file($d["archive"])) error("パラメータが不正です: ".$d["archive"]);
		if (static::cmd()) return null;
		error("このファイルの内容を表示できません");

	}

	private static function cmd() {
		$d=&static::$d;
		$t=bsdTar();
		if ($t) {
			if (exec([$t,"-tf",$d["archive"]])) return true;
		}
		$t=gnuTar();
		if ($t) {
			if (exec([$t,"-tf",$d["archive"]])) return true;
		}
		return false;
	}

}

?>