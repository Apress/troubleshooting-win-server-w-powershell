Function Get-TSUptime {
    param ($ComputerName = $env:COMPUTERNAME)
    $WmiOS = Get-WmiObject Win32_OperatingSystem -ComputerName $ComputerName
    [Management.ManagementDateTimeConverter]::ToDateTime($WmiOS.LastBootUpTime)
}

Function Get-TSFreeSpace {
    [CmdletBinding()]
    param ($ComputerName = $env:COMPUTERNAME)
    $allDisks = Get-WmiObject -ComputerName $ComputerName -Class Win32_LogicalDisk -Filter "DriveType='3'"
    foreach ($disk in $allDisks) {
        $results += [PSCustomObject]@{
            'ComputerName' = $disk.DeviceID
            'FreeSpace(GB)'= $([int]($disk.FreeSpace / 1GB))
            'Size(GB)'= $([int]($disk.size / 1GB))
        }
    }
    $results
}