
Break

#region Getting Events
Get-EventLog –LogName System | Where-Object {$_.Eventid –eq 1074}
#endregion

#region Simple SystemLogSearch
$systemlog = Get-EventLog –LogName System
$systemlog | Select-Object -Property InstanceId, Message, Source, TimeGenerated | Export-Csv -Path "c:\reports\systemlog.csv"
#endregion

#region HTML Reports Header
# A here block for a simple HTML header
$htmlformat = @"
<style>
Table {border-width: 1px; border-style: solid; border-color: black;}
TH {border-width: 1px; padding: 3px; border-style: solid;}
TR:nth-child(even) {background: #CCC}
TR:nth-child(odd) {background: #FFF}
</style>
"@
#endregion

#region Working with the Chapter 2 module
# Once loaded the Chapter 2 module, then you can run this next line.
# This uses the Function Against the System file and saves the HTML report.
Get-TSHtmlReport -LogName System -SaveFile C:\Reports\test2.html
# This next line just calls the HTML file you created above
& C:\Reports\test2.html
#endreigon

#region Writing to Event Log
# Must be run as Administrator 
New-EventLog -LogName Application -Source “My Application”
Write-EventLog -LogName Application -Source “My Application” -EventId 1 -Message 'Hello to EventLog'
#endregion
