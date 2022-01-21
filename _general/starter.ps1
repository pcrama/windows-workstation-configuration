Function Start-OnceOnly {
    param (
        [string]$exe,
        [string]$ProcessName
    )
    try {
        $_ = Get-Process $ProcessName -ErrorAction Stop
        Write-Host "$ProcessName already running"
        Return $False
    } catch {
        Write-Host "Starting $exe"
        try {
            $cmd = Get-Command -Name $exe
            if ($cmd.CommandType -eq [System.Management.Automation.CommandTypes]::Application) {
                Start-Process -FilePath $cmd.Path
            } else {
                . $cmd.Path
            }
            Return $True
        } catch {
            Write-Host "Skipping $ProcessName"
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

Set-Location $Env:HOME

$HaveISlept = $false

Try {
#     Write-Host "Trying to start wezterm"
#     # https://superuser.com/a/1297072: msys2/mingw64 shell setup for ConEmu, adapted for wezterm
#     $Env:CHERE_INVOKING = 1
#     $Env:MSYS2_PATH_TYPE = 'inherit'
#     $Env:MSYSTEM = 'MINGW64'
#     # terminalpp attempt, but their command line parsing is off so I can't start a session with a space in the name.
#     # I could still try to set 'mingw64 (msys2)' as the default choice, but since terminalpp is not faster than
#     # mintty, I won't bother.
#     # Start-Process -FilePath ($Env:SCOOP + "\apps\terminalpp\current\terminalpp.exe") -ArgumentList @("--here", "--session=mingw64 (msys2)")
#     # Bug-To-Force-Starting-MinTTY-Start-Process -WindowStyle Hidden -FilePath ($Env:SCOOP + "\shims\wezterm.exe") -ArgumentList @('start', '--', 'c:\msys64\usr\bin\bash.exe', '--login', '-i')
#     # Start-Process -WindowStyle Hidden -FilePath ($Env:SCOOP + "\shims\terminalpp.exe") -ArgumentList @("-e", "c:\msys64\msys2_shell.cmd", "-mingw64", "-defterm", "-where", $Env:USERPROFILE, "-use-full-path", "-shell", "bash")
# } catch {
#     Write-Host "Falling back on mintty"
    Start-Process -WindowStyle Hidden -FilePath "c:\msys64\msys2_shell.cmd" -ArgumentList @("-mingw64", "-mintty", "-where", $Env:USERPROFILE, "-use-full-path", "-shell", "bash")
    Start-Sleep 10
# }

    Wait-ProcessExistsP bash

    # Start other programs with a certain delay...
    Foreach ($x in (@("flux", 10),
                    @("multicommander", 10),
                    @("copyq", 10),
                    @("WinCompose", 10),
                    @(($Env:SCOOP + "\apps\workrave\current\lib\Workrave.exe"), 10, "workrave"),
                    @("touchcursor", 10),
                    @("greenshot", 10)
                   )) {
        If ($x[2] -eq $null) {
            $procname = $x[0]
        } else {
            $procname = $x[2]
        }
        If (Start-OnceOnly -exe $x[0] -ProcessName $procname) {
            Wait-ProcessExistsP $procname
            Write-Host "Sleeping $($x[1])s after $($x[0]) started"
            Start-Sleep $x[1]
            $HaveISlept = $true
        }
    }
    Write-Host "All done!"
    Start-Sleep 1
    If (-not $HaveISlept) {
        Start-Sleep 9
    }
} Catch {
    Write-Host "Caught an error: $_"
    Pause
}
