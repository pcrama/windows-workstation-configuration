Function Start-OnceOnly {
    param (
	    [string]$shim,
		[int]$delay
	)
    try {
	    $_ = Get-Process $shim -ErrorAction Stop
		Write-Host "$shim already running"
    } catch {
		Write-Host "Starting $shim"
		Start-Sleep $delay
	    . $shim
	}
}

Function Wait-Process {
    param (
	    [string]$shim
	)
    $stop = (Get-Date).AddMinutes(3)
    while ((Get-Date) -lt $stop) {
        try {
            $_ = Get-Process $shim -ErrorAction Stop
			Write-Output "$shim OK..."
            Break
        } catch {
            Start-Sleep 5
			Write-Output "$shim not started?"
        }
    }
}

$basename = "ConEmu64"
$conemu = "$(Resolve-Path (scoop which "$basename"))"
$scoop = "$(Resolve-Path "$(Split-Path -Path "$conemu" -Parent)\..\..\..")"
$ssh_agent = "$scoop\apps\git\current\usr\bin\ssh-agent.exe"
Start-Process -WindowStyle Hidden -FilePath "$ssh_agent" -ArgumentList @("$conemu", "-LoadCfgFile", "$($scoop)\persist\conemu\conemu.xml")
Wait-Process bash

$Env:HOME=$Env:HOMEDRIVE + $Env:HOMEPATH

# Start other programs with a certain delay...
Foreach ($x in (@("greenshot", 10), @("ditto", 10), @("multicommander", 10), @("keypirinha", 10))) {
    Start-OnceOnly $x[0] $x[1]
    Wait-Process $x[0]
}
