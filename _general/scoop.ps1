iex (new-object net.webclient).downloadstring('https://get.scoop.sh')

pause

scoop install git
$scoop="$(Resolve-Path "$(Split-Path (scoop which 7z))\..\..\..")"
git clone https://github.com/pcrama/windows-workstation-configuration.git -o https-origin "$scoop\persist"

Write-Host "Pull https://github.com/lukesampson/scoop/pull/1934"
cd "$scoop\apps\scoop\current"
git remote add pcrama-https https://github.com/pcrama/scoop.git
git config --local user.name "Philippe Crama"
git config --local user.email "dontsendmespam@example.com"
git fetch pcrama-https virustotal-apikey-fixes-20171231
git merge pcrama-https/virustotal-apikey-fixes-20171231

scoop bucket add extras

Write-Host "Pull https://github.com/lukesampson/scoop-extras/pull/731"
cd "$scoop\buckets\extras"
git remote add pcrama-https https://github.com/pcrama/scoop-extras.git
git config --local user.name "Philippe Crama"
git config --local user.email "dontsendmespam@example.com"
git fetch pcrama-https master
git merge pcrama-https/master

scoop bucket add scoop-buckets https://github.com/pcrama/scoop-buckets.git

pause
scoop install zip conemu ditto fd ripgrep smallcliutils greenshot multicommander keypirinha emacs

. "$scoop\persist\_general\makeshortcut.ps1"
