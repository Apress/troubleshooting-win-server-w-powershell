
Break

#region Listing Module Paths
$env:PSModulePath -split ';' 
#endregion

#region Adding a folder to Module Path
New-Item -Path c:\MyModules -ItemType Directory
$env:PSModulePath = $env:PSModulePath + ";c:\MyModules"
#endregion

#region Creating Desired State Configuration 
#This creates configures a MOF File for use with DSC
configuration troubleshootingiis
{
	param ($ComputerName)
	node $ComputerName {
		windowsfeature iis {
			ensure = "Present"
			name = "web-server"
		}
	}
}
#endregion

#region Create MOF File
#This command creates the MOF file
troubleshootiis 
#endregion

#region Region building MOF Files for Desired State Configuration
Troubleshootingiis –ComputerName MyServer01

#endregion

#region Checking for matching state and modifying existing state if needed
#This checks to see if a remote server has a desired state configuration.
#If not, the configuration is pushed to that server
If (-not (Test-DscConfiguration -CimSession Server-02))
{
	Start-DscConfiguration -CimSession server-02
}

#endregion
#region testing a server's configuration against known MOF File
#This tests the remote server for a DSC configuration
Test-dscconfiguration –cimsession server-02
#endregion

#region Restoring previous configuration
#This will restore the previous configuration
Restore-DscConfiguration -CimSession Server-02
#endregion

#region Enable PowerShell Remoting
Enable-PSRemoting
#endregion

#region Adding computer to trusted hosts for remoting
Set-Item WSMan:\localhost\Client\TrustedHosts -value Server01
#endregion

#region Start remoting
Enter-PSSession -ComputerName Server01
#endregion

#region Scheduled Job
$jobOption = New-ScheduledJobOption -RequireNetwork -WakeToRun -RunElevated
$jobTrigger = New-JobTrigger -Weekly -DaysOfWeek Monday, Tuesday, Wednesday, Thursday, Friday -At '1:00AM'
Register-ScheduledJob -Trigger $jobTrigger `
    -ScheduledJobOption $jobOption `
    -ScriptBlock { Get-Service } `
    -MaxResultCount 5 `
    -Name "ListServices"

# Prove that it exists
Get-ScheduledJob

# Listing jobs previously run
Get-Job ListServices | Format-Table -AutoSize

# Looking at Job results, while keeping data in the job history
# May have to change your ID Number for your environment
Receive-Job -Id 15 -Keep
#endregion
