#! /usr/bin/env php
<?php

require_once("analyze.php");
require_once("execute.php");
require_once("docs.php");
require_once("lib.php");

$d=new data();

argAnalyze($d);

switch ($d->mode) {
	case CMMain:    execute\main($d); break;
	case CMHelp:    help();           break;
	case CMVersion: version();        break;
}