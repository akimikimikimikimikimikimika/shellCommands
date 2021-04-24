#! /usr/bin/env pwsh

. "$($PSScriptRoot)/lib.ps1"
. "$($PSScriptRoot)/analyze.ps1"
. "$($PSScriptRoot)/execute.ps1"
. "$($PSScriptRoot)/docs.ps1"

$d=[Data]::new()

$arguments=$args
argAnalyze($d)

switch ($d.mode) {
	{$_ -eq [CM]::main} { [Execute]::new($d); break }
	{$_ -eq [CM]::help} { help; break }
	{$_ -eq [CM]::version} { version; break }
}