# https://blogs.msdn.microsoft.com/virtual_pc_guy/2010/09/23/a-self-elevating-powershell-script/
# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)

# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

$adapterName = "Wi-Fi"
$IPType = "IPv4"
$adapter = Get-NetAdapter -Name $adapterName
$dnsclient = Get-DnsClientServerAddress -InterfaceAlias $adapterName -AddressFamily $IPType
# www.quad9.net: 9.9.9.9 & 149.112.112.112
# google public DNS: 8.8.8.8 & 8.8.4.4
$externalIP1 = "9.9.9.9"
$externalIP2 = "149.112.112.112"
If (($externalIP1 -In $dnsclient.ServerAddresses) -Or ($externalIP2 -In $dnsclient.ServerAddresses)) {
    Write-Host "$externalIP1 or $externalIP2 already in $adapterName's DNS settings, switching back to DHCP"
    # Check to see if we are currently running "as Administrator"
    # (script restarts itself as administrator if needed, see end of script)
    if ($myWindowsPrincipal.IsInRole($adminRole)) {
        Set-DnsClientServerAddress -InterfaceAlias $adapterName -ResetServerAddresses
    }
} else {
    Write-Host "Setting up $externalIP1 & $externalIP2 as DNS servers"
    # Check to see if we are currently running "as Administrator"
    # (script restarts itself as administrator if needed, see end of script)
    if ($myWindowsPrincipal.IsInRole($adminRole)) {
        Set-DnsClientServerAddress -InterfaceAlias $adapterName -ServerAddresses ($externalIP1, $externalIP2)
    }
}

# Check to see if we are currently running "as Administrator" and
# restart if necessary
if (!$myWindowsPrincipal.IsInRole($adminRole)) {
    Write-Host "We are not running 'as Administrator' - so relaunch..."

    # Create a new process object that starts PowerShell
    $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell"

    # Specify the current script path and name as a parameter
    $newProcess.Arguments = "-ExecutionPolicy RemoteSigned & '" + $script:MyInvocation.MyCommand.Path + "'"
    # Indicate that the process should be elevated
    $newProcess.Verb = "runas"

    # Start the new process
    [System.Diagnostics.Process]::Start($newProcess)
}
