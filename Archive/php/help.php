<?php

require_once("util.php");
require_once("create.php");
require_once("expand.php");
require_once("paths.php");

class Help {

	public static function main($arg) {
		switch ($arg) {
			case "":case "general":case "help":
				static::genericHelp(); break;
			case "create":case "compress":
				Create::help(); break;
			case "expand":case "extract":case "decompress":
				Expand::help(); break;
			case "paths":case "list":
				Paths::help(); break;
			default:
				error("指定したヘルプテキストはありません: ".$arg);
		}
	}

	private static function genericHelp() {
		helpText(<<<Help

			使い方:
			arc [command] [options]...

			アーカイブを取り扱います
			それぞれのコマンドの使い方は arc help [command] を参照

			arc create [archive path] [options] [input file paths]...
			arc compress [input file paths] [options]
			 アーカイブを生成します

			arc expand [archive path] [options]
			arc extract [archive path] [options]
			arc decompress [archive path] [options]
			 アーカイブを展開します

			arc paths [archive path] [options]
			arc list [archive path] [options]
			 アーカイブに含まれるファイルの一覧を表示します

		Help);
	}

}

?>