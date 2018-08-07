$scoop_shims="$(Resolve-Path "$(scoop prefix scoop)\..\..\..\shims")"
$persist_dir="$(split-path $scoop_shims)\persist"
$ssh_agent="$(split-path -Path "$scoop_shims")\apps\git\current\usr\bin\ssh-agent.exe";
$conemu="$scoop_shims\ConEmu64.exe";
$Shell = New-Object -ComObject ("WScript.Shell");
$ShortCut = $Shell.CreateShortcut($env:USERPROFILE + "\Desktop\startit.lnk");
$ShortCut.TargetPath="PowerShell.exe";
$ShortCut.Arguments="-NoProfile -ExecutionPolicy RemoteSigned `"$($persist_dir)\_general\starter.ps1`""
$ShortCut.WorkingDirectory=$(split-path $scoop_shims);
$ShortCut.WindowStyle = 1;
$ShortCut.Hotkey = "CTRL+ALT+SHIFT+F12";
$ShortCut.IconLocation = $conemu + ", 0";
$ShortCut.Description = "Start ConEmu with shared ssh-agent"
$ShortCut.Save()
