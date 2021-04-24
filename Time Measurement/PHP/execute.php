<?php

namespace execute;

require_once("lib.php");

$d=null;
$o=null;
$e=null;
$r=null;

$res="";
$ec=0;

function main($rd) {
	global $d,$o,$e,$r,$res,$ec;
	$d=$rd;
	$o=co2f($d->out,STDOUT);
	$e=co2f($d->err,STDERR);
	$r=ro2f($d->result);

	switch ($d->multiple) {
		case MMNone:   single(); break;
		case MMSerial: serial(); break;
		case MMSpawn:  spawn();  break;
	}

	fwrite($r,$res);
	closeIO($o);
	closeIO($e);
	closeIO($r);
	exit($ec==-1?1:$ec);
}

function single() {
	global $d,$res,$ec;
	$p=new SP($d->command);

	$st=hrtime(true);
	$p->run();
	$en=hrtime(true);

	$t=descTime($en-$st);
	$e=$p->descEC();
	$res=clean(<<< "Result"
		time: $t
		process id: $p->pid
		$e
	Result).PHP_EOL;
	$ec=$p->ec;
}

function serial() {
	global $d,$res,$ec;
	$pl=SP::multiple($d->command);
	$lp=$pl[count($pl)-1];

	$st=hrtime(true);
	foreach ($pl as $p) {
		$p->run();
		if ($p->ec!=0) {
			$lp=$p;
			break;
		}
	}
	$en=hrtime(true);

	$res=implode(PHP_EOL,[
		"time: ".descTime($en-$st),
		...array_map(function($p){ return "process$p->order id: ".($p->pid<0?"N/A":$p->pid); },$pl),
		$lp->descEC(),""
	]);
	$res="time: ".descTime($en-$st).PHP_EOL;
	foreach ($pl as $p) $res.="process$p->order id: ".($p->pid<0?"N/A":$p->pid).PHP_EOL;
	$res.=$lp->descEC().PHP_EOL;

	$ec=$lp->ec;
}

function spawn() {
	global $d;
	$pl=SP::multiple($d->command);

	$st=hrtime(true);
	foreach ($pl as $p) $p->start();
	foreach ($pl as $p) $p->wait();
	$en=hrtime(true);

	SP::collect($pl,$st,$en);
}

class SP {
	private $r;
	private $s;
	private $args;
	public $order=0;
	public $pid=-1;
	public $ec=0;

	public function __construct($args) {
		$this->args=$args;
	}

	public static function multiple($commands) {
		$n=1;
		$l=[];
		foreach ($commands as $c) {
			$p=new SP($c);
			$p->order=$n;
			array_push($l,$p);
			$n++;
		}
		return $l;
	}

	public static function collect($pl,$st,$en) {
		global $res,$ec;
		$ec=0;

		$r=["time: ".descTime($en-$st)];
		foreach ($pl as $p) {
			if ($p->ec>$ec) $ec=$p->ec;
			array_push($r,"process$p->order id: $p->pid",$p->descEC());
		}
		array_push($r,"");
		$res=implode(PHP_EOL,$r);
	}

	public function start() {
		global $o,$e;
		try {
			$this->r=proc_open($this->args,[0=>STDIN,1=>$o,2=>$e],$p);
			if ($this->r==false) throw Exception();
		}
		catch(Exception $e) {
			$as=implode(" ",$this->args);
			error("実行に失敗しました: $as");
		}
	}

	public function wait() {
		$s=proc_get_status($this->r);
		$ec=proc_close($this->r);
		if (!$s["running"]) $ec=$s["exitcode"];
		$this->pid=$s["pid"];
		$this->ec=$ec;
		$this->s=$s;
	}

	public function run() {
		$this->start();
		$this->wait();
	}

	public function descEC() {
		$s=$this->s;
		return $s["signaled"] ? "terminated due to signal ".strval($s["termsig"]) : "exit code: ".strval($this->ec);
	}

}



function co2f($d,$inherit) {
	switch ($d) {
		case "inherit": return $inherit;
		case "discard": return ["file","/dev/null","w"];
		default: return $this->fh($d);
	}
}

function ro2f($d) {
	switch ($d) {
		case "stdout": return STDOUT;
		case "stderr": return STDERR;
		default: return $this->fh($d);
	}
}

$opened=[];
function fh($path) {
	if (array_key_exists($path,$this->opened)) return $this->opened[$path];
	try {
		$f=fopen($path,"a");
		$this->opened[$path]=$f;
		return $f;
	}
	catch(Exception $e){ error("指定したパスには書き込みできません: ".$path); }
}

function closeIO($fh) {
	if (is_resource($fh)) fclose($fh);
}



function descTime($nSec) {
	$t="";
	$r=$nSec/(3600*1e+9);$v=floor($r);
	if ($v>=1) $t.="${v}h ";
	$r=($r-$v)*60;$v=floor($r);
	if ($v>=1) $t.="${v}m ";
	$r=($r-$v)*60;$v=floor($r);
	if ($v>=1) $t.="${v}s ";
	$r=($r-$v)*1000;
	$t.=sprintf("%07.3fms",$r);
	return $t;
}

function descEC($s) {
	return $s["signaled"] ? "terminated due to signal ".strval($s["termsig"]) : "exit code: ".strval($s["exitcode"]);
}