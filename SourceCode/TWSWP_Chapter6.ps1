
Break

#region getting processes
Get-Process

# Search just for PowerShell
Get-Process | Where-Object {$_.name –eq “powershell”}

# Search for a name "iexplore"
Get-Process -Name iexplore

# Create a quick report of running processes
Get-Process | 
Select-Object -Property Id, Name, WS, CPU | 
ConvertTo-Html -Title "Proccess on $($env:COMPUTERNAME)" | 
Out-File -FilePath "C:\Reports\Processes.html"
#endregion

#region Fancy Process Report f0r 7 random processes
$header = @"
<style>
BODY{background-color:white;}
TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}
TH{border-width: 1px;padding: 0px;border-style: solid;border-color: black;}
TD{border-width: 1px;padding-left: 0px;padding-right: 15px;border-style: solid;border-color: black;}
</style>
"@

$serv = Get-Service | 
    Select-Object -Property ServiceName, DisplayName, Status | 
    Get-Random -Count 7 | 
    ConvertTo-Html -Fragment

ConvertTo-Html  -Head $header -body "<H2>Seven Random Services</H2>$serv" | 
    Out-File -FilePath "C:\Reports\Processes.html"
#endregion

#region Sample sending Email with PowerShell
# Note the backtick character at the end of the lines
Send-MailMessage -To "User@your.company.suffix" `
    -From "reports@your.company.suffix" `
    -Subject 'Report of Processes' `
    -Body "$(Get-Content C:\Reports\Processes.html)" `
    -BodyAsHtml `
    -SmtpServer smtp.your.company.suffix
#endregion

#region Sample script for pulling information from remote computers
$inputFile = Get-Content -Path “C:\JustComputerNames.txt”
$reportData = @{}
Foreach ($computer in $inputFile) {
    $reportData += Get-Process -ComputerName $computer
}
$reportData | 
    Select-Object -Property MachineName, Id, Name, WS, CPU | 
    ConvertTo-Html -Title "Proccesses on Computer List" | 
    Out-File -FilePath "C:\Reports\Processes.html"

Send-MailMessage -To "User@your.company.suffix" `
    -From "reports@your.company.suffix" `
    -Subject 'Report of Processes' `
    -Body "List of Processes on the computer list." `
    -BodyAsHtml `
    -Attachments 'C:\Reports\Processes.html' `
    -SmtpServer smtp.your.company.suffix
#endregion

#region Stopping a process
Get-Process | 
    Where-Object Name –match notepad | 
    Stop-Process
#endregion

#region Start a process
Start-Process Notepad
#endregion

#region stopping remotely using Invoke-Command
Invoke-Command -ComputerName server01 -ScriptBlock { Get-Process | where name -match notepad }
#endregion

#region Getting Owner of a process
(Get-WmiObject -Class Win32_Process -ComputerName server01 | 
where Name -match PowerShell.exe).GetOwner() | 
Select-Object Domain, User | Format-List
#endregion

#region Getting the path of the executable running the process
# Using WMI
Get-WmiObject -Class Win32_Process -Filter "Name='Notepad.exe'" |
    Select-Object -ExpandProperty CommandLine

# Using CIM
Get-CimInstance -ClassName Win32_Process -Filter "Name='Notepad.exe'"
#endregion

