Enum CM {
	main
	help
	version
}

Enum MM {
	none
	serial
	spawn
	thread
}

class Data {
	[CM]$mode=[CM]::main
	[array]$command=@()
	[string]$stdout="inherit"
	[string]$stderr="inherit"
	[string]$result="stderr"
	[MM]$multiple=[MM]::none
}

function exitWithError([string]$text) {
	$text >> "/dev/stderr"
	exit(1)
}

function clean([string]$text) {
	return $text -ireplace "`t+",""
}