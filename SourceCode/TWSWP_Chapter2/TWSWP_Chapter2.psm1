Function Get-TSHtmlReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("System", "Application", "Security")]
        [string]$LogName,
        
        [Parameter(Mandatory=$true)]
        [string]$SaveFile
    )
    Begin {
        $htmlformat = @"
<style>
Table {border-width: 1px; border-style: solid; border-color: black;}
TH {border-width: 1px; padding: 3px; border-style: solid;}
TR:nth-child(even) {background: #CCC}
TR:nth-child(odd) {background: #FFF}
</style>
"@

        $HTMLhead += “<H1>Event log information from $($env:COMPUTERNAME)</H1>”
        $HTMLhead += “<H2>Log name: $($LogName)</H2>”
    }
    Process {
        $events = Get-EventLog -LogName $LogName -Newest 50 | Select-Object -Property Index, EventID, Message
    }
    End {
        $events | ConvertTo-Html -head $HTMLhead -body $htmlformat | Out-File -FilePath $SaveFile
    }
}
