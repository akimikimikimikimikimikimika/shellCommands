. "$($PSScriptRoot)/lib.ps1"

class Execute {

	hidden $d

	hidden $res=""
	hidden $ec=0

	Execute($rd) {
		$this.d=$rd

		switch ($this.d.multiple) {
			{$_ -eq [MM]::none} { $this.single() }
			{$_ -eq [MM]::serial} { $this.serial() }
			{$_ -eq [MM]::spawn} { $this.spawn() }
		}

		switch ($this.d.result) {
			"stdout" { $this.res >> "/dev/stdout" }
			"stderr" { $this.res >> "/dev/stderr" }
			Default {
				try{ $this.res >> $this.d.result }
				catch{ exitWithError("書き込みに失敗しました: $($this.d.result)") }
			}
		}
		exit($this.ec)
	}

	hidden single() {
		$p=[SP]::new($this.d.command,($this.d.command -Join " "),$this)

		$st=Get-Date
		$p.run()
		$en=Get-Date

		$this.res=@(
			"time: $($this.descTime($st,$en))"
			"process id: $($p.pid)"
			$p.descEC()
		) -join "`n"
		$this.ec=$p.ec
	}

	hidden serial() {
		$pl=[SP]::multiple($this.d.command,$this)
		$lp=$pl[$pl.Count-1]

		$st=Get-Date
		foreach ($p in $pl) {
			$p.run()
			if ($p.ec -ne 0) {
				$lp=$p
				break
			}
		}
		$en=Get-Date

		$this.res=((
			@("time: $($this.descTime($st,$en))")+
			($pl | ForEach-Object {"process$($p.order) id: $(If ($p.pid -lt 0) {"N/A"} else {$p.pid})"})+
			@($lp.descEC())
		) -join "`n")
		$this.ec=$lp.ec
	}

	hidden spawn() {
		$pl=[SP]::multiple($this.d.command,$this)

		$st=Get-Date
		foreach ($p in $pl) { $p.start() }
		foreach ($p in $pl) { $p.wait() }
		$en=Get-Date

		[SP]::collect($pl,$st,$en,$this)
	}

	hidden [string]descTime([DateTime]$st,[DateTime]$en) {
		$ts=-$st.Subtract($en)
		$t=""
		$v=[Math]::Floor($ts.TotalHours)
		if ($v -ge 1) { $t+="$($v)h " }
		$v=$ts.Minutes
		if ($v -ge 1) { $t+="$($v)m " }
		$v=$ts.Seconds
		if ($v -ge 1) { $t+="$($v)s " }
		$t+="$($ts.Milliseconds)ms"
		return $t
	}

}

class SP {

	hidden [System.Diagnostics.Process]$p
	hidden [string]$description
	hidden $o
	hidden $e
	[int]$order = 0
	[int]$pid = -1
	[int]$ec = 0

	SP([array]$arg,[string]$desc,[Execute]$exe) {
		$this.p=[System.Diagnostics.Process]::new()
		$si=$this.p.StartInfo
		$si.UseShellExecute=$false
		$si.CreateNoWindow=$true
		$this.o=$exe.d.stdout
		$this.e=$exe.d.stderr
		$si.RedirectStandardOutput=($this.o -ne "inherit")
		$si.RedirectStandardError=($this.e -ne "inherit")
		$firstArg=$true
		foreach ($ar in $arg) {
			if ($firstArg) {
				$si.FileName=$ar
				$firstArg=$false
			}
			else { $si.ArgumentList.Add($ar) }
		}
		$this.description=$desc
	}
	[array]static multiple([array]$commands,[Execute]$exe) {
		$n=1
		$sh=$env:SHELL
		if ($Null -eq $sh) { $sh="/bin/sh" }
		return ($commands | ForEach-Object {
			$p=[SP]::new(@($sh,"-c",$_),$_,$exe)
			$p.order=$n
			$n+=1
			$p
		})
	}
	static collect([array]$pl,[DateTime]$st,[DateTime]$en,[Execute]$exe) {
		$exe.res=((
			@("time: $($exe.descTime($st,$en))")+
			@($pl | ForEach-Object {
				if ($_.ec -gt $exe.ec) { $exe.ec=$_.ec }
				return @(
					"process$($_.order) id: $($_.pid)",
					$_.descEC()
				)
			})
		) -join "`n")
	}
	start() {
		try {
			$this.p.Start()
			$this.pid=$this.p.Id
		}
		catch {
			exitWithError("実行に失敗しました: $($this.description)")
		}
	}
	wait() {
		if (($this.o -ne "inherit") -and ($this.o -ne "discard")) { $this.p.StandardOutput.ReadToEnd() >> $this.o }
		if (($this.e -ne "inherit") -and ($this.e -ne "discard")) { $this.p.StandardError.ReadToEnd() >> $this.e }
		$this.p.WaitForExit()
		$this.ec=$this.p.ExitCode
	}
	run() {
		$this.start()
		$this.wait()
	}
	[string]descEC() {
		return "exit code: $($this.ec)"
	}

}