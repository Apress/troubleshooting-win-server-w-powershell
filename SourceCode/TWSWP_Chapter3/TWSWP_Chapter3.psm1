Function Get-TSDiskSizes {
    param ($ComputerName = $env:COMPUTERNAME)
    Get-WmiObject -Class Win32_LogicalDisk -ComputerName $ComputerName |
        Format-Table -Property DeviceID,
            DriveType,
            @{Name = 'FreeSpace(GB)' ; Expression = {$_.FreeSpace / 1GB} ; FormatString = "N2" },
            @{Name = 'Size(GB)' ; Expression = {$_.Size / 1GB} ; FormatString = "N2" }
}