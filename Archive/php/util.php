<?php

$id=getmypid();
$cwd=getcwd();
$env=getenv();

/*
	chdir($path) → chdir($path)
	mv($src,$dst) → rename($src,$dst)
	cp($src,$dst) → copy($src,$dst)
	mkdir($path) → mkdir($path,0777,TRUE)
	isfile($path) → is_file($path)
	isdir($path) → is_dir($path)
	islink($path) → is_link($path)
	basename($path) → basename($path)
	hardlink($src,$dst) → link($src,$dst)
	writable(path) → is_writable($path)
*/

function rm($path) {
	if (!is_dir($path)) unlink($path);
	else {
		$fl=fileList($path);
		foreach ($fl as $i) rm($path.DIRECTORY_SEPARATOR.$i);
		rmdir($path);
	}
}
function fileList($path) {
	return array_filter(scandir($path),function($v){return $v!="."&&$v!="..";});
}
function println($text) {
	print($text);
	print(PHP_EOL);
}
function which($cmd) {
	$r=getData(["which",$cmd]);
	if ($r!=null && $r!="") return $r;
	$r=getData(["where",$cmd]);
	if ($r!=null && $r!="") return $r;
	return null;
}
function getdir($path) {return realpath(dirname($path));}
function concatPath(...$path) {
	array_walk($path,function(&$p){$p=rtrim($p,"\\/");});
	return implode(DIRECTORY_SEPARATOR,$path);
}
$i=function($v){return $v;};

class Temp {
	public $tmpDir=null;
	public function __construct() {
		$t=tempnam(sys_get_temp_dir(),"archive".getmypid());
		$this->tmpDir=$t;
		unlink($t);
		mkdir($t);
	}
	public function blank() {
		$io=fopen(concatPath($this->tmpDir,".blank"));
		fclose($io);
	}
	public function done() {
		rm($this->tmpDir);
	}
}

function password() {
	if (which("read")!=null) {
		$p="";
		while ($p=="") {
			exec("read -s -p \"パスワード: \" text ; echo>&2 ; echo \$text",$o);
			if (count($o)>0) $p=rtrim($o[0]);
			else $p="";
			unset($o);
		}
		return $p;
	}
	else error("パスワードが指定できません");
}

function error($text) {
	fputs(STDERR,$text.PHP_EOL);
	exit(1);
}

function execute($cmd,$quiet=false) {
	global $env;

	if ($quiet) $d=[
		0=>STDIN,
		1=>["file","/dev/null","w"],
		2=>["file","/dev/null","w"]
	];
	else $d=[
		0=>STDIN,
		1=>STDOUT,
		2=>["file","/dev/null","w"]
	];
	$p=proc_open($cmd,$d,$pipes,null,$env);
	return proc_close($p);
}

function getData($cmd) {
	global $env;

	$p=proc_open($cmd,[
		0=>STDIN,
		1=>array("pipe","w"),
		2=>array("file","/dev/null","w")
	],$pipes,null,$env);
	$t=null;
	if (is_resource($p)) {
		$t=rtrim(stream_get_contents($pipes[1]));
		fclose($pipes[1]);
		if (proc_close($p)==0) return $t;
		else return null;
	}
}

function bsdTar() {
	$l=array(which("bsdtar"),which("tar"));
	foreach ($l as $t) if ($t!=null) {
		$v=getData([$t,"--version"]);
		if (preg_match("/bsdtar/",$v)) return $t;
	}
	return null;
}

function gnuTar() {
	$l=array(which("gnutar"),which("tar"),which("gtar"));
	foreach ($l as $t) if ($t!=null) {
		$v=getData([$t,"--version"]);
		if (preg_match("/GNU tar/",$v)) return $t;
	}
	return null;
}

function helpText($text) {
	$text=preg_replace("/\n\t+/","\n",$text);
	$text=preg_replace("/\r?\n$/","",$text);
	println($text);
}

function levelCast($val) {
	if (preg_match("/^[1-9]$/",$val)) $l=array($val,string(ceil(int($val)/2)*2-1),$val,$val);
	else if (preg_match("/^1[0-9]$/",$val)) {
		$l=array("9","9",$val,$val);
		if (int($val)>12) $l[2]="12";
	}
	else if ($val=="default") $l=array("6","5","1","3");
	else $l=array("6","5","1","3");
	return $l;
}

class CompressType {
	public $keys=[];
	public $compressCmd=[];
	public $decompressCmd=[];
	public $tarExt="";
	public $ext="";
	public function __construct($data) {
		$this->keys=$data[0];
		$this->compressCmd=$data[2];
		$this->decompressCmd=$data[4];
		$this->tarExt=$data[1];
		$this->ext=$data[3];
	}
	public static function each($l) {
		return array_map(function($a){return new CompressType($a);},$l);
	}
}

$compressors=CompressType::each([
	[["z","Z","compress","lzw"],"tar.Z",["compress","-f"],"Z",["uncompress","-f"]],
	[["gz","gzip","deflate"],"tgz",["gzip","-f","-k"],"gz",["gzip","-d","-f"]],
	[["bz","bz2","bzip","bzip2"],"tbz2",["bzip2","-z","-f","-k"],"bz2",["bzip2","-d"]],
	[["xz","lzma"],"txz",["xz","-z","-f","-k","-T0"],"xz",["xz","-d","-f"]],
	[["lz","lzip"],"tlz",["lzip","-f","-k"],"lz",["lzip","-d","-f"]],
	[["lzo","lzop"],"tar.lzo",["lzop","-f"],"lzo",["lzop","-d","-f"]],
	[["br","brotli"],"tar.br",["brotli","-f"],"br",["brotli","-d","-f"]],
	[["zst","zstd","zstandard"],"tar.zst",["zstd","-f","-T0"],"zst",["zstd","-d","-f","-T0"]],
	[["lz4"],"tar.lz4",["lz4","-f"],"lz4",["lz4","-d","-f"]]
]);

function switches(&$d,$params,$inputs,$max=0) {
	global $argv;

	$args=$argv;

	$var=null;
	$multiple=false;
	$sharp=null;
	$step=1;

	$noSwitches=false;

	foreach (array_slice($args,2) as $a) {

		$match=false;

		if ($a=="--") $noSwitches=$match=true;
		if ($a=="") $match=true;

		if (!$noSwitches) {

			foreach ($params as $cmd) {
				foreach ($cmd[0] as $p) {
					if ($p=="-#") {
						$s=preg_match("/^\-([0-9]+)$/",$a);
						if ($s!=null) {
							$match=true;
							$sharp=$s[1];
						}
					}
					else if ($p==$a) $match=true;
					if ($match) break;
				}
				if ($match) {
					$var=null;
					foreach (array_slice($cmd,1) as $act) {
						if ($act[0]=="var") {
							$var=$act[1];
							$multiple=count($act)==3;
						}
						if ($act[0]=="write") {
							if ($sharp!=null) {
								$d[$act[1]]=$sharp;
								$sharp=null;
							}
							else $d[$act[1]]=$act[2];
						}
					}
					break;
				}
			}

			if (!$match) if (preg_match("/^\-+/",$a)) error("このスイッチは無効です: ".$a);

			if (!$match) if ($var!=null) {
				if ($multiple) array_push($d[$var],$a);
				else {
					$d[$var]=$a;
					$var=null;
				}
				$match=true;
			}

		}

		if (!$match) {
			if ($max>0 && $step>$max) error("パラメータが多すぎます");
			$i=min($step,count($inputs))-1;
			if (gettype($d[$inputs[$i]])=="array") array_push($d[$inputs[$i]],$a);
			else $d[$inputs[$i]]=$a;
			$step+=1;
		}

	}

}

?>