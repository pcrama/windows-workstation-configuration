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
    "$opt\bin" +
    ";$($Env:HOME)\AppData\Roaming\Python\Scripts" +
    ";C:\VASCO\Programs\Vasco.Tim.Runner\Vasco.Tim.Runner_2_4_1_7" +
    ";C:\VASCO\Programs\DPEmulator\DPEmulator_1_0_5_1_forVC_3_15_0_beta2" +
    ";C:\VASCO\Programs\DpxDumpPro" +
    ";C:\VASCO\Programs\DigipassSequencer\20170519_2_3_6_2_QA" +
    ";C:\VASCO\Programs\bin" +
    ";C:\VASCO\Programs\IASLicenseGenerator" +
    ";$($Env:SCOOP)\apps\emax64\current\emax64\bin" +
    ";" + $Env:PATH)

$Env:GRAPHVIZ_DOT = $Env:SCOOP + "\shims\dot.exe"

$basename = "ConEmu64.exe"
$scoop = $Env:SCOOP
$conemu = "$scoop\apps\conemu\current\$basename"
$ssh_agent = "$scoop\apps\git\current\usr\bin\ssh-agent.exe"
Write-Host "SCOOP=`"$($Env:SCOOP)`"`nbasename=`"$basename`"`nconemu=`"$conemu`"`nscoop=`"$scoop`"`nssh_agent=`"$ssh_agent`""
Start-Process -WindowStyle Hidden -FilePath "$ssh_agent" -ArgumentList @("$conemu", "-LoadCfgFile", "$($scoop)\persist\conemu\conemu.xml")
Wait-ProcessExistsP bash

# Start other programs with a certain delay...
Foreach ($x in (@("flux", 10),
                @("multicommander", 10),
                @("workrave", 10),
                @("ditto", 10),
                @("WinCompose", 10),
                @("greenshot", 10),
                @("keypirinha", 10, "keypirinha-x64"))) {
    If (Start-OnceOnly $x[0]) {
        if ($x[2] -eq $null) {
            $procname = $x[0]
        } else {
            $procname = $x[2]
        }
        Wait-ProcessExistsP $procname
        Write-Host "Sleeping $($x[1])s after $($x[0]) started"
        Start-Sleep $x[1]
    }
}
