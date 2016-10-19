
Break

#region Listing Hotfixes
Get-HotFix
Get-WmiObject -Class Win32_QuickFixEngineering
Get-CimInstance -ClassName Win32_QuickFixEngineering
#endregion

#region List last boot time of a computer
[Management.ManagementDateTimeConverter]::ToDateTime((Get-WmiObject Win32_OperatingSystem -ComputerName $env:ComputerName -ErrorAction Stop).LastBootUpTime)
#endregion

#region Uninstalling HotFix on remote server
$ComputerName = 'Server01'
$HotFixID = '123456789'
$RemoteProcess = "wusa.exe /uninstall /KB:$HotFixID /quiet /norestart"
([WMICLASS]"\\$ComputerName\ROOT\CIMV2:win32_process").Create($RemoteProcess)
#endregion

#region Quick check for pending restarts
Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending"
#endregion

#region Checking restarts on remote server
$ComputerName = “$env:ComputerName”
$connectToRegistry = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine", $ComputerName.computername)
$fullRegPath = $connectToRegistry.OpenSubKey( "Software\Microsoft\Windows\CurrentVersion\Component Based Servicing" )
$subKeyNames = $fullRegPath.GetSubKeyNames()
if ($subKeyNames -contains 'RebootPending') {
    Write-Output "$ComputerName Needs reboot"
} else {
    Write-Output "No reboot required"
}
$fullRegPath.Close() 
$connectToRegistry.Close()
#endregion

#region Other registry keys to check
<#
HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\
HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\
HKLM\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName\ComputerName
HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\PendingFileRenameOperations
#>
#endregion
