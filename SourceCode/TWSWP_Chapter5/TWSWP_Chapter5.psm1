Function Get-TsSystemUptime {
    [CmdletBinding(SupportsShouldProcess=$true, 
                  ConfirmImpact='Medium')]
    Param (
        # A name of a computer, or computers.
        [string[]]$ComputerName = $env:COMPUTERNAME
    )
    Begin { }
    Process {
        # Sets an empty array for this variable
        $results = @()
        Foreach ($comp in $computerName) {
            # Creates a new PowerShell Object
            $intResults = New-Object PSObject
            Write-Verbose -Message "Checking '$comp'"
            if (Test-Connection -ComputerName $comp -Quiet -Count 2) {
                Try {
                    $operatingSystem = Get-WmiObject Win32_OperatingSystem -ComputerName $comp -ErrorAction Stop
                    $lastStartTime = [Management.ManagementDateTimeConverter]::ToDateTime($operatingSystem.LastBootUpTime)
                    [double]$TotalHours = "{0:N2}" -f ((New-TimeSpan -Start (Get-Date "$lastStartTime") -End (Get-Date)).TotalHours)
                    $intResults = [PSCustomObject]@{
                        'ComputerName' = $comp
                        'LastStartTime' = $lastStartTime
                        'TotalHours' = $TotalHours
                    }
                    $results += $intResults
                }
                Catch {
                    Write-Warning -Message "The computer '$comp' was not reachable because $_."
                }
            } else {
                Write-Warning -Message "The computer '$comp' was not pingable."
            }
        }
    }
    End { $results }
}

Function Uninstall-TSHotFix {
    [CmdletBinding()]
    Param (
        # This is the HotFix ID, can be either KB plus number or just number.
        [Parameter(Mandatory=$true)]
        $HotFixID
    )
    $HotFixID = $HotFixID -replace 'kb',''
    $FoundHotFix = Get-HotFix | where HotfixID -match $HotFixID
    if ($FoundHotFix) {
        wusa /uninstall /kb:$HotFixID /quiet /norestart
    } else {
        Write-Warning -Message "Cannot find HotFixID '$HotFixID'"
    }
}
