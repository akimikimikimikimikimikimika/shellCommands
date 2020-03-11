<?php

require_once("util.php");

class Expand {

	private static $d=[
		"archive"=>"",
		"out"=>"",
		"outType"=>"same",
		"encrypted"=>false,
		"suppressExpansion"=>false
	];

	public static function help() {
		helpText(<<<Help

			arc expand [archive path] [options]
			arc extract [archive path] [options]
			arc decompress [archive path] [options]

			アーカイブを展開します
			圧縮ファイルを解凍します

			オプション

			-a [string],-i [string],--archive [string],--in [string]
			 アーカイブ•圧縮ファイルを指定します

			-d [string],-o [string],--dir [string],--out [string]
			 展開する場所を指定します
			 アーカイブの場合は指定したディレクトリ内に,圧縮ファイルの場合は指定したパスに保存します
			 指定したディレクトリが存在しなければ自動的にディレクトリを生成します
			--cwd
			 カレントディレクトリに展開します
			--same
			 アーカイブファイルのあるディレクトリに展開します (デフォルト)

			-s,--suppress-expansion
			 .tar.gz など,圧縮したtarアーカイブファイルを受け取った場合に,圧縮を解凍してもtarを展開しないようにします

			-e,--encrypt
			 暗号化ファイルを展開する場合は,このオプションを使用してください
			 パスワードは後で指定します

		Help);
	}

	public static function main() {
		static::analyze();
		static::core();
	}

	private static function analyze() {
		$d=&static::$d;
		global $cwd;

		switches($d,[
			[["-a","-i","--archive","--in"],["var","archive"]],
			[["-d","-o","--dir","--out"],["var","out"]],
			[["--cwd"],["write","outType","cwd"],["write","out",""]],
			[["--same"],["write","outType","same"],["write","out",""]],
			[["-e","--encrypted"],["write","encrypted",true]],
			[["-s","--suppress-expansion"],["write","suppressExpansion",true]],
		],["archive"],1);

		if (!is_file($d["archive"])) error("指定したパスは不正です: ".$d["archive"]);

		if ($d["outType"]=="cwd" && $d["out"]=="") $d["out"]=$cwd;
		if ($d["outType"]=="same" && $d["out"]=="") $d["out"]=getdir($d["archive"]);

	}

	private static function core() {
		$d=static::$d;
		$t=new Temp();
		if (is_file($d["out"])) {
			if (static::decompress($t)) static::move($t,true);
			else {
				$t->done();
				error("このファイルはこの場所には展開できません");
			}
		}
		else if (is_dir($d["out"])) {
			if ($d["suppressExpansion"]) {
				if (static::decompress($t)) static::move($t,true);
			}
			else {
				if (static::extract($t)) static::move($t);
				else if (static::decompress(t)) static::move($t,true);
				else {
					$t->done();
					error("このファイルは展開できません");
				}
			}
		}
		else if (is_link($d["out"])) {
			$t->done();
			error("リンクが不正です: ".$d["out"]);
		}
		else {
			$pd=getdir($d["out"]);
			if (!is_dir($pd)) {
				try{mkdir(getdir($d["out"]));}
				catch(Exception $e) {
					$t->done();
					error("この場所に展開できません");
				}
			}
			if ($d["suppressExpansion"]) {
				if (static::decompress($t)) static::move($t,true);
			}
			else {
				if (static::extract($t)) static::move($t);
				else if (static::decompress($t)) static::move($t,true);
				else {
					$t->done();
					error("このファイルは展開できません");
				}
			}
		}
		$t->done();
	}

	private static function extract($t) {
		$d=static::$d;
		$done=false;
		if ($d["password"]) $p=password();

		$cmd=which("unzip");
		if (!$done && $cmd!=null) {
			$arg=[$cmd,"-qq",$d["archive"],"-d",$t->tmpDir];
			if ($d["encrypted"]) array_splice($arg,1,0,["-P",$p]);
			if (execute($arg,true)==0) $done=true;
		}

		$cmd=bsdTar();
		if (!$done && $cmd!=null) {
			$arg=[$cmd,"-xf",$d["archive"],"-C",$t->tmpDir];
			if (execute($arg,true)==0) $done=true;
		}

		$cmd=gnuTar();
		if (!$done && $cmd!=null) {
			$arg=[$cmd,"-xf",$d["archive"],"-C",$t->tmpDir];
			if (execute($arg,true)==0) $done=true;
		}

		$cmd=which("7z");
		if (!$done && $cmd!=null) {
			$arg=[$cmd,"x","-t7z",$d["archive"],"-o".$t->tmpDir];
			if ($d["encrypted"]) array_push($arg,"-p"+$p);
			if (execute($arg,true)==0) $done=true;
		}

		return $done;
	}

	private static function decompress($t) {
		global $compressors;
		$d=static::$d;
		$arc=concatPath($t->tmpDir,basename($d["archive"]));
		link($d["archive"],$arc);
		$done=false;
		foreach ($compressors as $c) {
			$cmd=which($c->decompressCmd[0]);
			if ($cmd==null) continue;
			$c->decompressCmd[0]=$cmd;
			array_push($c->decompressCmd,$arc);
			if ($c->ext=="lz4")
				$a=preg_replace("/\.lz4$/","",$arc);
				if ($a==$arc) array_push($c->decompressCmd,$a.".out");
				else array_push($c->decompressCmd,$a);
			if (execute($c->decompressCmd,true)==0) $done=true;
			break;
		}
		if (is_file($arc)) rm($arc);
		return $done;
	}

	private static function move($t,$one=false) {
		$d=static::$d;
		$fl=fileList($t->tmpDir);
		if (count($fl)==1 && $one) {
			if (is_file($d["out"])) rm($d["out"]);
			if (is_dir($d["out"])) {
				$p=concatPath($d["out"],$fl[0]);
				if (is_file($p)) rm($p);
			}
			rename($fl[0],$d["out"]);
		}
		else {
			try {
				if (is_file($d["out"])) error("この場所には展開できません");
				else if (!is_dir($d["out"])) mkdir($d["out"]);
				foreach ($fl as $f) rename(concatPath($t->tmpDir,$f),concatPath($d["out"],$f));
			}
			catch(Exception $e) {error("このファイルはこの場所には展開できません");}
		}
	}

}

?>