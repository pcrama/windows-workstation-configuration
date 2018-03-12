Function Start-OnceOnly {
    param (
        [string]$shim
    )
    try {
        $_ = Get-Process $shim -ErrorAction Stop
        Write-Host "$shim already running"
        Return $False
    } catch {
        Write-Host "Starting $shim"
        try {
            . $shim
            Return $True
        } catch {
            Write-Host "Skipping $shim"
            Return $False
        }
    }
}

Function Wait-ProcessExistsP {
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

$scriptName = & { $myInvocation.ScriptName }
$Env:SCOOP = Split-Path -Path (Split-Path -Path (Split-Path -Path (Resolve-Path $scriptName) -Parent) -Parent) -Parent
Write-Host "SCOOP=`"$($Env:SCOOP)`""
$Env:PATH = ($Env:PATH).Replace("%SCOOP%", $Env:SCOOP)
Write-Host "Initial Path=$($Env:PATH)"

$Env:HOME = $Env:HOMEDRIVE + $Env:HOMEPATH
$opt = $Env:HOME + "\opt"
$Env:PATH = (
    "$opt\emaxw64\bin" +
    ";$opt\bin" +
    ";$($Env:HOME)\AppData\Roaming\Python\Scripts" +
    ";$opt\vasco\DigipassSequencer-20170519_2_3_6_2_QA" +
    ";$opt\vasco\DPEmulator_1_0_5_0_forVC_3_15_0" +
    ";$opt\vasco\DpxDumpPro" +
    ";$opt\vasco\bin" +
    ";" + $Env:PATH)

$basename = "ConEmu64.exe"
$conemu = "$(Resolve-Path (scoop which "$basename"))"
$scoop = $Env:SCOOP
$ssh_agent = "$scoop\apps\git\current\usr\bin\ssh-agent.exe"
Write-Host "SCOOP=`"$($Env:SCOOP)`"`nbasename=`"$basename`"`nconemu=`"$conemu`"`nscoop=`"$scoop`"`nssh_agent=`"$ssh_agent`""
Start-Process -WindowStyle Hidden -FilePath "$ssh_agent" -ArgumentList @("$conemu", "-LoadCfgFile", "$($scoop)\persist\conemu\conemu.xml")
Wait-ProcessExistsP bash

# Start other programs with a certain delay...
Foreach ($x in (@("flux", 10),
                @("workrave", 10),
                @("greenshot", 10),
                @("ditto", 10),
                @("multicommander", 10),
                @("keypirinha", 10))) {
    If (Start-OnceOnly $x[0]) {
        Wait-ProcessExistsP $procname
        Write-Host "Sleeping $($x[1])s after $($x[0]) started"
        Start-Sleep $x[1]
    }
}
