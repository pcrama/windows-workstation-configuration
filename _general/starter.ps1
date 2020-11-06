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
# Even though msys2 will set HOME anyway, already prepare it in the
# environment in case tools are started from e.g. multicommander:
$Env:HOME = $Env:USERPROFILE

Write-Host "HOME='$Env:HOME'`nInitial Path=$(($Env:PATH).Replace(";", "`n`t"))"

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
    ";" + $Env:PATH)

$Env:GRAPHVIZ_DOT = $Env:SCOOP + "\shims\dot.exe"

Start-Process -WindowStyle Hidden -FilePath "c:\msys64\msys2_shell.cmd" -ArgumentList @("-mingw64", "-mintty", "-where", $Env:USERPROFILE, "-use-full-path", "-shell", "bash")

Wait-ProcessExistsP bash

# Start other programs with a certain delay...
Foreach ($x in (@("flux", 10),
                @("multicommander", 10),
                @("copyq", 10),
                @("WinCompose", 10),
                @("stretchly", 10),
                @("greenshot", 10)
               )) {
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
