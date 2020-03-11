<?php

require_once("util.php");

class Create {

	private static $d=[
		"archive"=>"",
		"inFile"=>[],
		"type"=>"zip",
		"mode"=>"default",
		"level"=>"default",
		"format"=>"default",
		"single"=>false,
		"excludeHiddenFiles"=>true,
		"encrypted"=>false,
		"encryptType"=>"default",
		"prior"=>null
	];

	public static function help() {
		helpText(<<<Help

			arc create [archive path] [options] [input file paths]...
			arc compress [input file path]... [options]

			アーカイブを生成します
			生成するにあたり,コンピュータで利用可能な方法を選択して実行します
			オプションによってはいずれの方法でも生成できない場合があり,その時にはエラーを返します

			オプション

			[input file path]...
			-i [string]...,--in [string]...
			 アーカイブに含めるファイルを指定します

			[archive path]
			-a [string],-o [string],--archive [string],--out [string]
			 生成するアーカイブファイルの保存場所を指定します

			-t [enum],--type [enum]
			 アーカイブの種類を指定します
			 zip  zipアーカイブ (--zip,デフォルト)
			 tar  tarアーカイブ (--tar)
			 7z   7zアーカイブ (--7z)
			 この他にも対応しているフォーマットがあります。詳しくは後述

			-p [enum],--prior [enum]
			 生成方法を指定します (シェルコマンド)
			 アーカイブの種類によって利用可能な生成方法は異なります (後述)
			 指定したオプション次第では指定した方法では生成されないことがあります

			-#,-l [int],--level [int]
			 圧縮率を指定します
			 1~9 の整数で指定し,数値が大きいと圧縮率が高くなります
			 デフォルトは6
			 ※ tarオプションでは例外があります
			  -m lz4 の場合は 1~12 で指定し,デフォルトは1です
			  -m zstd の場合は 1~19 で指定し,デフォルトは3です
			  -m stored の場合はこのオプションは無効です
			  -m compress の場合はこのオプションは無効です

			zipアーカイブのオプション

			 生成方法 (優先順)
			  7z  7zコマンド
			  zip zipコマンド
			  tar tarコマンド

			 -m [enum],--mode [enum]
			  圧縮モードを指定します
			  store,copy  非圧縮 (デフォルト)
			  gz,deflate  Deflate圧縮
			  bz,bzip2    BZIP2圧縮
			  xz,lzma     LZMA圧縮

			 -e,--encrypt [enum]
			  アーカイブを暗号化します
			  パスワードは後で指定します
			  [enum] に次のうちいずれかの値を指定した暗号化の方法を指定できます
			   zipcrypto ZIP標準の暗号システム (デフォルト)
			   aes128    AES128暗号
			   aes192    AES192暗号
			   aes256    AES256暗号

			tarアーカイブのオプション

			 生成方法 (優先順)
			  tar    tarコマンド
			  gnutar gtarコマンド
			  7z     7zコマンド

			 -m [enum],--mode [enum]
			  圧縮モードを指定します
			  store,copy  非圧縮 (.tar,デフォルト)
			  gz,deflated Deflate圧縮 (.tar.gz)
			  bz,bzip2    BZIP2圧縮 (.tar.bz2)
			  xz,lzma     LZMA圧縮 (.tar.xz)
			  lzip        LZIP圧縮 (.tar.lz)
			  lzop        LZOP圧縮 (.tar.lzop)
			  lz4         LZ4圧縮 (.tar.lz4)
			  brotli      Brotli圧縮 (.tar.br)
			  zstd        Zstandard圧縮 (.tar.zst)

			 -f [enum],--format [enum]
			  tarのフォーマットを指定します
			  cpio  cpioフォーマット
			  shar  sharフォーマット
			  ustar ustarフォーマット
			  gnu   GNU tarフォーマット
			  pax   paxフォーマット (デフォルト)

			 -s,--single
			  -i で単一のファイルを指定した場合には,tarでアーカイブにせず圧縮ファイルを生成します。
			  例えば, -m gz とした場合, file は file.tar.gz ではなく file.gz になります。
			  -m store の場合はファイルが単純にコピーされます。

			 --include-hidden-files
			  macOSの隠しファイルもアーカイブします
			  これらにはFinderで使用されるデータも含み,展開時にそれらが復元されますが,他のプラットフォームでは可視ファイルとして展開されます

			7zアーカイブのオプション

			 生成方法 (優先順)
			  7z  7zコマンド
			  tar tarコマンド

			 -m [enum],--mode [enum]
			  圧縮モードを指定します
			  stored,copy 非圧縮
			  gz,deflate  Deflate圧縮
			  bz,bzip2    BZIP2圧縮
			  xz,lzma     LZMA圧縮
			  lzma2       LZMA2圧縮 (デフォルト)

			 -e,--encrypt
			  アーカイブを暗号化します
			  パスワードは後で指定します

			 -e he,--encrypt he
			  暗号化するにあたって,ヘッダも暗号化します
			  これにより, arc paths などでファイルの中身を表示できなくなります

			-tオプションで指定可能な値
			 zip   zipアーカイブ (--zip)
			 tar   tarアーカイブ (--tar)
			 7z    7zアーカイブ (--7z)

			 gzip  Gzip      (-t tar -m gzip -s と同等)
			 bzip2 Bzip2     (-t tar -m bzip2 -s と同等)
			 xz    xz        (-t tar -m xz -s と同等)
			 lzip  Lzip      (-t tar -m lzip -s と同等)
			 lzop  Lzop      (-t tar -m lzop -s と同等)
			 lz4   Lz4       (-t tar -m lz4 -s と同等)
			 br    Brotli    (-t tar -m brotli -s と同等)
			 zstd  Zstandard (-t tar -m zstd -s と同等)

			 --gzip,--bzip2,... などでも指定可能

		Help);
	}

	public static function main($a) {
		$d=&static::$d;

		static::analyze($a);

		switch ($d["type"]) {
			case "zip": static::Zip()::run($d); break;
			case "tar": static::Tar()::run($d); break;
			case "7z": static::Sz()::run($d); break;
			default: error("アーカイブタイプが不正です: ".$d["type"]);
		}

	}

	private static function analyze($a) {
		$d=&static::$d;
		global $compressors;

		switch ($a) {
			case "create": $i=["archive","inFile"]; break;
			case "compress": $i=["inFile"]; break;
		}

		$p=[
			[["-a","-o","--archive","--out"],["var","archive"]],
			[["-i","--in"],["var","inFile",true]],
			[["-t","--type"],["var","type"]],
			[["-m","--mode"],["var","mode"]],
			[["-l","--level"],["var","level"]],
			[["-#"],["write","level"]],
			[["-f","--format"],["var","format"]],
			[["-p","--prior"],["var","prior"]],
			[["-s","--single"],["write","single",true]],
			[["--include-hidden-files"],["write","excludeHiddenFiles",false]],
			[
				["-e","--encrypt"],
				["write","encrypted",true],
				["var","encryptType"]
			],
			[["--zip"],["write","type","zip"]],
			[["--tar"],["write","type","tar"]],
			[["--7z"],["write","type","7z"]]
		];

		foreach ($compressors as $c) {
			$l=array_map(function($k){return "--".$k;},$c->keys);
			array_push($p,[$l,["write","type",$c->keys[0]]]);
		}

		switches($d,$p,$i);

		foreach ($compressors as $c) {
			$match=false;
			foreach ($c->keys as $k) if ($k==$d["type"]) $match=true;
			if ($match) {
				$d["type"]="tar";
				$d["mode"]=$c->keys[0];
				$d["single"]=true;
				break;
			}
		}

		$ad=$d["archive"];
		if ($ad!=null) {
			while (!is_dir($ad)) $ad=getdir($ad);
			if (!is_writable($ad)) error("この場所には保存できません");
		}

	}

	private static function Zip() {
		return new class {

			private static $run7z=null;
			private static $runZip=null;
			private static $runTar=null;
			private static $d=null;

			public static function run(&$d) {
				static::$d=&$d;

				static::$run7z=which("7z");
				static::$runZip=which("zip");
				static::$runTar=bsdTar();

				$m=static::modeAnalyze();
				$l=levelCast($d["level"]);
				$e=static::encryptionAnalyze();
				Create::archiveAnalyze("zip");

				$p=$d["prior"];
				if ($p=="7z" && static::$run7z!=null) static::szCmd(static::$run7z,$m[0],$l[1],$e[0]);
				else if ($p=="zip" && static::$runZip!=null) static::zipCmd(static::$runZip,$m[1],$l[0]);
				else if ($p=="tar" && static::$runTar!=null) static::tarCmd(static::$runTar,$m[2],$e[2]);
				else if (static::$run7z!=null) static::szCmd(static::$run7z,$m[0],$l[1],$e[0]);
				else if (static::$runZip!=null) static::zipCmd(static::$runZip,$m[1],$l[0]);
				else if (static::$runTar!=null) static::tarCmd(static::$runTar,$m[2],$e[2]);
				else error("条件に合致したzipを生成する手段が見つかりませんでした");

			}

			private static function modeAnalyze() {
				$d=static::$d;
				$ms=$d["mode"];

				switch ($ms) {
					case "store":case "copy":case "default":
						$m=["Copy","store","store"]; break;
					case "gz":case "deflate":
						$m=["Deflate","deflate","deflate"]; break;
					case "deflate64":
						$m=["Deflate64","deflate","deflate"]; break;
					case "bz":case "bzip2":
						$m=["BZip2","bzip2",""];
						static::$runTar=null; break;
					case "xz":case "lzma":
						$m=["LZMA","",""];
						static::$runZip=static::$runTar=null; break;
					case "ppmd":
						$m=["PPMd","",""];
						static::$runZip=static::$runTar=null; break;
					default:
						$m=["Copy","store","store"];
				}

				return $m;
			}

			private static function encryptionAnalyze() {
				$d=static::$d;

				if ($d["encrypted"]) switch ($d["encryptType"]) {
					case "zipcrypto":case "default":
						$e=["ZipCrypto","-e","zipcrypt"]; break;
					case "aes128":
						$e=["AES128","","aes128"];
						static::$runZip=null; break;
					case "aes192":
						$e=["AES192","","aes256"];
						static::$runZip=null; break;
					case "aes256":
						$e=["AES256","","aes256"];
						static::$runZip=null; break;
					default:
						$e=["ZipCrypto","-e","zipcrypt"];
				}
				else $e=[null,null,null];

				return $e;
			}

			private static function szCmd($cmd,$m,$l,$e) {
				$d=static::$d;

				$tmp=new Temp();
				$ap=concatPath($tmp->tmpDir,".archive");
				if (count($d["inFile"])>0) {
					$arg=[$cmd,"a","-tzip",$ap,"-bso0","-bsp0","-sas","-xr!.DS_Store","-mx=".$l,"-mm=".$m];
					if ($d["encrypted"]) {
						$p=password();
						array_push($arg,"-mem=".$e,"-p".$p);
					}
					$arg=array_merge($arg,$d["inFile"]);
					if (execute($arg,true)!=0) {
						$tmp->done();
						error("7zでエラーが発生しました");
					}
				}
				else {
					chdir($tmp->tmpDir);
					$tmp.blank();
					execute([$cmd,"a","-tzip",$ap,".blank"],true);
					execute([$cmd,"d","-tzip",$ap,".blank"],true);
					chdir($cwd);
				}
				rename($ap,$d["archive"]);
				$tmp->done();
			}

			private static function zipCmd($cmd,$m,$l) {
				$d=static::$d;

				$tmp=new Temp();
				$ap=concatPath($tmp->tmpDir,".archive");
				if (count($d["inFile"])>0) {
					$arg=[$cmd,$ap,"-qr"];
					$arg=array_merge($arg,$d["inFile"]);
					if ($m=="deflate" || $m=="bzip2") array_push($arg,"-".$l);
					if ($d["encrypted"]) array_push($arg,"-p",password());
					array_push($arg,"-x",".DS_Store");
					array_push($arg,"-Z",$m);
					if (execute($arg,true)!=0){
						$tmp->done();
						error("zipでエラーが発生しました");
					}
				}
				else {
					chdir($tmp->tmpDir);
					$tmp->blank();
					execute([$cmd,"-q",$ap,".blank"],true);
					execute([$cmd,"-dq",$ap,".blank"],true);
					chdir($cwd);
				}
				rename($ap,$d["archive"]);
				$tmp->done();
			}

			private static function tarCmd($cmd,$m,$e) {
				$d=static::$d;

				$tmp=new Temp();
				$ap=concatPath($tmp->tmpDir,".archive.zip");

				$arg=[$cmd,"-a","-cf",$ap,"--options","zip:compression=".$m];
				if ($d["encrypted"]) $arg[5].=",zip:encryption=".$e;
				array_push($arg,"--exclude",".DS_Store");

				if (count(d["inFile"])>0) {
					$arg=array_merge($arg,$d["inFile"]);
					if (execute($arg,true)!=0) {
						$tmp->done();
						error("tarでエラーが発生しました");
					}
				}
				else{
					chdir($tmp->tmpDir);
					$tmp->blank();
					array_push($arg,"--exclude",".blank",".blank");
					execute($arg,true);
					chdir($cwd);
				}
				rename($ap,$d["archive"]);
				$tmp->done();
			}

		};
	}

	private static function Tar() {
		return new class {

			private static $runBTar=null;
			private static $runGTar=null;
			private static $run7z=null;
			private static $d=null;

			public static function run(&$d) {
				static::$d=&$d;

				static::$runBTar=bsdTar();
				static::$runGTar=gnuTar();
				static::$run7z=which("7z");

				$m=static::modeAnalyze();
				$l=levelCast($d["level"]);
				$f=static::formatAnalyze();

				if (count($d["inFile"])==1 && $d["single"]) {
					$sf=$d["inFile"][0];
					if (is_file($sf)) {
						Create::archiveAnalyze($m->ext);
						static::comp($sf,$m,$l);
						return null;
					}
				}

				Create::archiveAnalyze($m->tarExt);

				$p=$d["prior"];
				if (($p=="bsdtar" || $p=="tar") && static::$runBTar!=null) static::tarCmd(static::$runBTar,$m,$l,$f[0]);
				else if ($p=="gnutar" && static::$runGTar!=null) static::tarCmd(static::$runGTar,$m,$l,$f);
				else if ($p=="7z" && static::$run7z!=null) static::szCmd(static::$run7z,$m,$l);
				else if (static::$runBTar!=null) static::tarCmd(static::$runBTar,$m,$l,$f);
				else if (static::$runGTar!=null) static::tarCmd(static::$runGTar,$m,$l,$f);
				else if (static::$run7z!=null) static::szCmd(static::$run7z,$m,$l);
				else error("条件に合致したtarを生成する手段が見つかりませんでした");

			}

			private static function modeAnalyze() {
				global $compressors;
				$d=static::$d;

				$ms=$d["mode"];
				$m=new CompressType([[],"tar",null,"",null]);

				if ($ms!="store" && $ms!="copy" && $ms!="default") foreach ($compressors as $c) {
					$match=false;
					foreach ($c->keys as $k) if ($k==$ms) $match=true;
					if ($match) {
						$m=$c;
						break;
					}
				}

				if ($m->compressCmd!=null) {
					$c=which($m->compressCmd[0]);
					if ($c!=null) $m->compressCmd[0]=$c;
					else error("コマンド \"$m->compressCmd[0]\" が利用できないため実行できません");
				}

				return $m;
			}

			private static function formatAnalyze() {
				$d=static::$d;
				$fs=$d["format"];

				switch ($fs) {
					case "default":
						$f="pax"; break;
					case "cpio":
						$f="cpio";
						static::$runGTar=null; break;
					case "shar":
						$f="shar";
						static::$runGTar=null; break;
					case "ustar":
						$f="ustar"; break;
					case "gnu":
						$f="gnu";
						static::$runBTar=null; break;
					case "pax":
						$f="pax"; break;
					default:
						$f="pax";
				}

				return $f;
			}

			private static function szCmd($cmd,$m,$l) {
				$d=static::$d;

				$tmp=new Temp();
				$ap=concatPath($tmp->tmpDir,".archive");
				if (count($d["inFile"])>0) {
					$arg=[$cmd,"a","-ttar",$ap,"-bso0","-bsp0","-sas"];
					if ($d["excludeHiddenFiles"]) array_push($arg,"-xr!.DS_Store");
					$arg=array_merge($arg,$d["inFile"]);
					if (execute($arg,true)!=0) {
						$tmp->done();
						error("7zでエラーが発生しました");
					}
				}
				else {
					chdir($tmp->tmpDir);
					$tmp->blank();
					execute([$cmd,"a","-ttar",$ap,".blank"],true);
					execute([$cmd,"d","-ttar",$ap,".blank"],true);
					chdir($cwd);
				}
				if ($m->compressCmd!=null) {
					static::compress($m->compressCmd,$l,$ap,$tmp);
					rename($ap.".".$m->ext,$d["archive"]);
				}
				else rename($ap,$d["archive"]);
				$tmp->done();
			}

			private static function tarCmd($cmd,$m,$l,$f) {
				$d=static::$d;

				$tmp=new Temp();
				$ap=concatPath($tmp->tmpDir,".archive");

				$arg=[$cmd,"-cf",$ap,"--format",$f];
				if ($d["excludeHiddenFiles"]) {
					array_push($arg,"--exclude",".DS_Store");
					$env["COPYFILE_DISABLE"]="1";
				}

				if (count($d["inFile"])>0) {
					$arg=array_merge($arg,$d["inFile"]);
					if (execute($arg,true)!=0) {
						$tmp->done();
						error("tarでエラーが発生しました");
					}
				}
				else {
					chdir($tmp->tmpDir);
					$tmp->blank();
					array_push($arg,"--exclude",".blank",".blank");
					execute($arg,true);
					chdir($cwd);
				}
				if ($m->compressCmd!=null) {
					static::compress($m->compressCmd,$l,$ap,$tmp);
					rename($ap.".".$m->ext,$d["archive"]);
				}
				else rename($ap,$d["archive"]);
				$tmp->done();
			}

			private static function comp($f,$m,$t) {
				$d=static::$d;
				if ($m->compressCmd!=null) {
					$fn=basename($f);
					$tmp=new Temp();
					$tf=concatPath($tmp->tmpDir,$fn);
					link($f,$tf);
					static::compress($m->compressCmd,$l,$tf,$tmp);
					mv($tf.".".$m->ext,$d["archive"]);
					$tmp->done();
				}
				else copy($f,$d["archive"]);
			}

			private static function compress($m,$l,$ap,$tmp) {
				$d=static::$d;
				$cmd=basename($m[0]);
				if ($cmd=="lz4") array_push($m,"-".$l[2]);
				else if ($cmd=="zstd") array_push($m,"-".$l[3]);
				else if ($cmd!="compress") array_push($m,"-".$l[0]);
				array_push($m,$ap);
				if ($cmd=="lz4") array_push($m,$ap.".lz4");
				if (execute($m,true)!=0) {
					$tmp->done();
					error("コマンド \"$cmd\" でエラーが発生しました");
				}

			}

		};
	}

	private static function Sz() {
		return new class {

			private static $run7z=null;
			private static $runTar=null;
			private static $d=null;

			public static function run(&$d) {
				static::$d=&$d;

				static::$run7z=which("7z");
				static::$runTar=bsdTar();

				$m=static::modeAnalyze();
				$l=levelCast($d["level"]);
				$he=false;
				if ($d["encrypted"]) {
					static::$runTar=false;
					if ($d["encryptType"]=="he") $he=true;
				}
				Create::archiveAnalyze("7z");

				$p=$d["prior"];
				if ($p=="7z" && static::$run7z!=null) static::szCmd(static::$run7z,$m,$l[1],$he);
				else if ($p=="tar" && static::$runTar!=null) static::tarCmd(static::$runTar);
				else if (static::$run7z!=null) static::szCmd(static::$run7z,$m,$l[1],$he);
				else if (static::$runTar!=null) static::tarCmd(static::$runTar);
				else error("条件に合致した7zを生成する手段が見つかりませんでした");

			}

			private static function modeAnalyze() {
				$d=static::$d;

				switch ($d["mode"]) {
					case "store":case "copy": $m="Copy"; break;
					case "gz":case "deflate": $m="Deflate"; break;
					case "bz":case "bzip2": $m="BZip2"; break;
					case "xz":case "lzma": $m="LZMA"; break;
					case "lzma2":case "default": $m="LZMA2"; break;
					default: $m="LZMA2";
				}

				return $m;
			}

			private static function szCmd($cmd,$m,$l,$he) {
				$d=static::$d;
				global $cwd;

				$tmp=new Temp();
				$ap=concatPath($tmp->tmpDir,".archive");
				if (count($d["inFile"])>0) {
					$arg=[$cmd,"a","-t7z",$ap,"-bso0","-bsp0","-sas","-xr!.DS_Store","-mx=".$l,"-m0=".$m];
					if ($d["encrypted"]) {
						$p=password();
						array_push($arg,"-p".$p);
						if ($he) array_push($arg,"-mhe=on");
					}
					$arg=array_merge($arg,$d["inFile"]);
					if (execute($arg,true)!=0) {
						$tmp->done();
						error("7zでエラーが発生しました");
					}
				}
				else {
					chdir($tmp->tmpDir);
					$tmp->blank();
					execute([$cmd,"a","-t7z",$ap,".blank"],true);
					execute([$cmd,"d","-t7z",$ap,".blank"],true);
					chdir($cwd);
				}
				rename($ap,$d["archive"]);
				$tmp->done();
			}

			private static function tarCmd($cmd) {
				$d=static::$d;

				$tmp=new Temp();
				$ap=concatPath($tmp->tmpDir,".archive.7z");

				$arg=[$cmd,"-a","-cf",$ap];
				array_push($arg,"--exclude",".DS_Store");

				if (count($d["inFile"])>0){
					$arg=array_merge($arg,$d["inFile"]);
					if (execute($arg,true)!=0) {
						$tmp->done();
						error("tarでエラーが発生しました");
					}
				}
				else {
					chdir($tmp->tmpDir);
					$tmp->blank();
					array_push($arg,"--exclude",".blank",".blank");
					execute($arg,true);
					chdir($cwd);
				}
				rename($ap,$d["archive"]);
				$tmp->done();
			}

		};
	}

	public static function archiveAnalyze($ext) {
		$d=&static::$d;
		global $cwd;
		if ($ext!="") $ext=".".$ext;
		if (count($d["inFile"])==1) $f=$d["inFile"][0].$ext;
		else $f="Archive".$ext;
		if ($d["archive"]==null) {
			if (!is_writable($cwd)) error("カレントディレクトリにアーカイブを書き出すことができません");
			$d["archive"]=$f;
		}
		if (is_dir($d["archive"])) $d["archive"]=concatPath($d["archive"],$f);
	}

}

?>