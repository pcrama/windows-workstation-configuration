iex (new-object net.webclient).downloadstring('https://get.scoop.sh')

pause

scoop install git
$scoop="$(Resolve-Path "$(Split-Path (scoop which 7z))\..\..\..")"
git clone https://github.com/pcrama/windows-workstation-configuration.git -o https-origin "$scoop\persist"

cd "$scoop\apps\scoop\current"
git remote add pcrama-https https://github.com/pcrama/scoop.git
git config --local user.name "Philippe Crama"
git config --local user.email "dontsendmespam@example.com"
git fetch pcrama-https virustotal-exception-handling
git merge pcrama-https/virustotal-exception-handling

scoop bucket add extras

cd "$scoop\buckets\extras"
git config --local user.name "Philippe Crama"
git config --local user.email "dontsendmespam@example.com"

scoop bucket add scoop-buckets https://github.com/pcrama/scoop-buckets.git

pause
scoop install 7zip copyq delta dngrep dust fd flux git graphviz greenshot imageglass multicommander notepadplusplus omnisharp oraclejre8 paint.net pdftk pdfxchangeeditor plantuml ripgrep smallcliutils stretchly sumatrapdf unison wincompose winmerge zeal zoxide

. "$scoop\persist\_general\makeshortcut.ps1"
