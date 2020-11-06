$persist_dir=Resolve-Path "$(scoop prefix scoop)\..\..\..\persist"
$Shell = New-Object -ComObject ("WScript.Shell");
$ShortCut = $Shell.CreateShortcut($env:USERPROFILE + "\Desktop\startit.lnk");
$ShortCut.TargetPath="PowerShell.exe";
$ShortCut.Arguments="-NoProfile -ExecutionPolicy RemoteSigned `"$persist_dir\_general\starter.ps1`""
$ShortCut.WorkingDirectory=$env:USERPROFILE;
$ShortCut.WindowStyle = 1;
$ShortCut.Hotkey = "CTRL+ALT+SHIFT+F12";
$ShortCut.IconLocation = "c:\msys64\usr\bin\mintty.exe,0";
$ShortCut.Description = "Start minTTY"
$ShortCut.Save()
