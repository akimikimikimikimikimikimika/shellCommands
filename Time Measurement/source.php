#! /usr/bin/env php
<?php

$command=[];
$out="inherit";
$err="inherit";
$result="stderr";
$multiple=false;

function main() {
	argAnalyze();
	new execute();
}

function argAnalyze() {
	global $argv,$command,$out,$err,$result,$multiple;
	$l=$argv;
	array_shift($l);
	if (count($l)==0) error("引数が不足しています");
	else {
		switch ($l[0]) {
			case "-h": case "help": case "-help": case "--help": help();
			case "-v": case "version": case "-version": case "--version": version();
		}
	}
	$noFlags=false;
	$key=null;
	foreach ($l as $a) {
		if ($noFlags) {array_push($command,$a);continue;}
		if ($key) {
			switch ($key) {
				case "stdout": $out=$a; break;
				case "stderr": $err=$a; break;
				case "result": $result=$a; break;
			}
			$key=null;
			continue;
		}
		switch ($a) {
			case "-o": case "-out": case "-stdout": $key="stdout"; break;
			case "-e": case "-err": case "-stderr": $key="stderr"; break;
			case "-r": case "-result": $key="result"; break;
			case "-m": case "-multiple": $multiple=true; break;
			default:
				$noFlags=true;
				array_push($command,$a);
		}
	}
	if (count($command)==0) error("実行する内容が指定されていません");
}

class execute {

	public function __construct() {
		global $command,$out,$err,$result,$multiple;
		$o=$this->co2f($out,STDOUT);
		$e=$this->co2f($err,STDERR);
		$r=$this->ro2f($result);

		$ec=0;
		if ($multiple) {
			$pl=[];
			$st=hrtime(true);
			foreach ($command as $c) {
				$this->run($c,$o,$e,$pid,$ec);
				array_push($pl,$pid);
				if ($ec!=0) break;
			}
			$en=hrtime(true);
			fwrite($r,"time: ".$this->descTime($en-$st).PHP_EOL);
			for ($n=0;$n<count($pl);$n++) fwrite($r,"process".($n+1)." id: ".$pl[$n].PHP_EOL);
			fwrite($r,"exit code: $ec".PHP_EOL);
		}
		else {
			$st=hrtime(true);
			$this->run($command,$o,$e,$pid,$ec);
			$en=hrtime(true);
			$t=$this->descTime($en-$st);
			fwrite($r,clean(<<< "Result"
				time: $t
				process id: $pid
				exit code: $ec
			Result).PHP_EOL);
		}
		fclose($r);
		exit($ec);
	}

	private function co2f($d,$inherit) {
		switch ($d) {
			case "inherit": return $inherit;
			case "discard": return ["file","/dev/null","w"];
			default: return $this->fh($d);
		}
	}

	private function ro2f($d) {
		switch ($d) {
			case "stdout": return STDOUT;
			case "stderr": return STDERR;
			default: return $this->fh($d);
		}
	}

	private $opened=[];
	private function fh($path) {
		if (array_key_exists($path,$this->opened)) return $this->opened[$path];
		try {
			$f=fopen($path,"a");
			$this->opened[$path]=$f;
			return $f;
		}
		catch(Exception $e){ error("指定したパスには書き込みできません: ".$path); }
	}

	private function run($c,$o,$e,&$pid,&$ec) {
		$r=proc_open($c,[0=>STDIN,1=>$o,2=>$e],$p);
		$pid=proc_get_status($r)["pid"];
		$ec=proc_close($r);
	}

	private function descTime($nSec) {
		$t="";
		$r=$nSec/(3600*1e+9);$v=floor($r);
		if ($v>=1) $t.="${v}h ";
		$r=($r-$v)*60;$v=floor($r);
		if ($v>=1) $t.="${v}m ";
		$r=($r-$v)*60;$v=floor($r);
		if ($v>=1) $t.="${v}s ";
		$r=($r-$v)*1000;
		$t.=sprintf("%.3fms",$r);
		return $t;
	}

}

function error($text) {
	fputs(STDERR,$text.PHP_EOL);
	exit(1);
}

function help() {
	print clean(<<<"Help"

		 使い方:
		  measure [options] [command] [arg1] [arg2]…
		  measure -multiple [options] "[command1]" "[command2]"…

		  [command] を実行し,最後にその所要時間を表示します

		  オプション

		   -o,-out,-stdout
		   -e,-err,-stderr
		    標準出力,標準エラー出力の出力先を指定します
		    指定しなければ inherit になります
		    • inherit
		     stdoutはstdoutに,stderrはstderrにそれぞれ出力します
		    • discard
		     出力しません
		    • [file path]
		     指定したファイルに書き出します (追記)

		   -r,-result
		    実行結果の出力先を指定します
		    指定しなければ stderr になります
		    • stdout,stderr
		    • [file path]
		     指定したファイルに書き出します (追記)

		   -m,-multiple
		    複数のコマンドを実行します
		    通常はシェル経由で実行されます
		    例えば measure echo 1 と指定していたのを

		     measure -multiple "echo 1" "echo 2"

		    などと1つ1つのコマンドを1つの文字列として渡して実行します

	Help);
	exit;
}

function version() {
	print clean(<<<"Version"

		 measure v2.0
		 PHP バージョン (measure-php)

	Version);
	exit;
}

function clean($text) {
	$text=preg_replace("/\n\t+/","\n",$text);
	$text=preg_replace("/^\t+/","",$text);
	return $text;
}

main();

?>