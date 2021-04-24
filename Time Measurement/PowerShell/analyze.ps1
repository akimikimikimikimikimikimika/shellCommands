. "$($PSScriptRoot)/lib.ps1"

Enum AnalyzeKey {
	none=0
	stdout=1
	stderr=2
	result=3
	multiple=4
}

function some($d) {
	Write-Output $d
}

$arguments=$Null

function argAnalyze($d) {
	$l=$arguments

	if ($l.Length -eq 0) { exitWithError("引数が不足しています") }
	else {
		switch -e ($l[0]) {
			{($_ -eq "-h") -or ($_ -eq "help") -or ($_ -eq "-help") -or ($_ -eq "--help")} {
				$d.mode=[CM]::help
			}
			{($_ -eq "-v") -or ($_ -eq "version") -or ($_ -eq "-version") -or ($_ -eq "--version")} {
				$d.mode=[CM]::version
			}
		}
	}

	[AnalyzeKey]$key=[AnalyzeKey]::none
	$n=-1
	foreach ($a in $l) {
		$n+=1
		if ($a -eq "") { continue }

		[bool]$proceed=$True
		switch ($a) {
			{($_ -eq "-m") -or ($_ -eq "-multiple")} {
				$d.multiple=[MM]::serial
				$key=[AnalyzeKey]::multiple
			}
			{($_ -eq "-o") -or ($_ -eq "-out") -or ($_ -eq "-stdout")} {
				$key=[AnalyzeKey]::stdout
			}
			{($_ -eq "-e") -or ($_ -eq "-err") -or ($_ -eq "-stderr")} {
				$key=[AnalyzeKey]::stderr
			}
			{($_ -eq "-r") -or ($_ -eq "-result")} {
				$key=[AnalyzeKey]::result
			}
			Default { $proceed=$False }
		}
		if ($proceed) { continue }

		if ($a.StartsWith("-")) {
			exitWithError("不正なオプションが指定されています")
		}
		elseif ($key -ne [AnalyzeKey]::none) {
			$proceed=$True
			switch ($key) {
				{$_ -eq [AnalyzeKey]::stdout} { $d.stdout=$a }
				{$_ -eq [AnalyzeKey]::stderr} { $d.stderr=$a }
				{$_ -eq [AnalyzeKey]::result} { $d.result=$a }
				{$_ -eq [AnalyzeKey]::multiple} {
					switch ($a) {
						"none" {
							$d.multiple=[MM]::none
						}
						{($_ -eq "serial") -or ($_ -eq "")} {
							$d.multiple=[MM]::serial
						}
						{($_ -eq "spawn") -or ($_ -eq "parallel")} {
							$d.multiple=[MM]::spawn
						}
						"thread" {
							$d.multiple=[MM]::thread
						}
						Default { $proceed=$False }
					}
				}
			}
			$key=[AnalyzeKey]::none
		}
		if ($proceed) { continue }

		$d.command=$l[$n..($l.Count-1)]
		break
	}

	if ($d.command.Count -eq 0) { exitWithError("実行する内容が指定されていません") }
}