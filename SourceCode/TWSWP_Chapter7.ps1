
Break

#region Start here
Get-Help Get-Service
Get-Service | Get-Member
#endregion

#region Restarting a Service
Get-Service | where Name -Match 'spooler' | Restart-Service
#endregion

#region Stopping Services
#Using a Method
(Get-Service -Name Spooler).Stop()
(Get-Service -Name Spooler -ComputerName Server01).Stop()

# Piping to Stop-Service
Get-Service -Name Spooler | Stop-Service
#endregion

#region Starting a service
Get-Service -Name Spooler | Start-Service
#endregion

#region Deleting a Service
(Get-WmiObject -Class Win32_Service -Filter "Name = 'ServiceName'").Delete()
#endregion


#region Modifying a Service
Get-Service -Name Spooler | Format-List -Property Name, DisplayName, Description
Set-Service -Name Spooler -Description "I changed the description!"

# Cannot see descirption through "Get-Service"
Get-Service -Name Spooler | Format-List -Property Name, DisplayName, Description

#Can be seen using WMI and CIM
Get-WmiObject -Class Win32_Service -Filter "Name = 'Spooler'" | Format-List -Property Name, DisplayName, Description
Get-CimInstance -ClassName Win32_Service -Filter "Name = 'Spooler'" | Format-List -Property Name, DisplayName, Description
#endregion

#region Suspending a service
Suspend-Service -Name Spooler | Start-Sleep -Seconds 30 | Resume-Service
#endregion

#region Changing attributes of a Service using WMI
$spoolerService = Get-WmiObject -Class Win32_Service -ComputerName Server01 -Filter "Name = 'spooler'"
$Account = '.\SvcAccount'
$password = 'P@$$w0rd'
$spoolerService.Change($null,$null,$null,$null,$null,$null,$Account,$password,$null,$null,$null)
<#
According to https://msdn.microsoft.com/en-us/library/windows/desktop/aa384901.aspx, other properties for Change are...
System.String DisplayName
System.String PathName
System.Byte ServiceType
System.Byte ErrorControl
System.String StartMode
System.Boolean DesktopInteract
System.String StartName
System.String StartPassword
System.String LoadOrderGroup
System.String[] LoadOrderGroupDependencies
System.String[] ServiceDependencies
#>
#endregion

#region Getting Running services for multiple servers and saving
Get-Service -ComputerName server01. Server02, server03 | 
    where Status -EQ Running | 
    Select-Object -Property Name,
        @{Name = 'RequiredServices' ; Expression = { $_.RequiredServices -join ';'}},
        CanPauseAndContinue,
        CanShutdown,
        CanStop,
        DisplayName,
        @{Name='DependentServices';Expression = { $_.DependentServices -join ';'}},
        MachineName,
        ServiceName,
        @{Name='ServicesDependedOn';Expression = { $_.ServicesDependedOn -join ';'}},
        ServiceHandle,
        Status,
        ServiceType,
        Site,
        Container | 
    Export-Csv -Path “c:\reports\services-list.csv” -NoTypeInformation

Send-MailMessage -To boss@your.company.suffix `
    -Cc you@your.company.suffix `
    -SmtpServer smtp.company.suffix `
    -From reports@your.company.suffix `
    -Subject 'Services Listing from Servers' `
    -Body 'List of services running on Server01, Server02, and Server03' `
    -Attachments “c:\reports\services-list.csv”
#endregion





