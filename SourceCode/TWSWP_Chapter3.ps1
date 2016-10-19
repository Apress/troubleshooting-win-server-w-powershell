
Break

#region Disks
Get-Disk
Get-PhysicalDisk
Get-WmiObject -Class Win32_LogicalDisk
Get-CimInstance -ClassName Win32_LogicalDisk
#endregion

#region Shares
Get-WmiObject -Class win32_share | Select-Object Name, Path, Description, Type
Get-SmbShareAccess -Name admin$ | Format-Table -AutoSize

# Note, the share name you are looking for has to exist.
# In this example I used SYSVOL.
Get-WmiObject -Class Win32_LogicalShareAccess |
    Where-Object SecuritySetting -Match 'sysvol' |
    Select-Object -Property SecuritySetting, Trustee, AccessMask |
    Format-Table -AutoSize
#endregion

#region Getting ACL
Get-Acl -Path C:\Reports | Format-Table -Wrap -AutoSize
Get-Acl -Path C:\Reports | Select-Object -ExpandProperty Access | Format-Table -AutoSize
#endregion

#region Setting ACL
# Change the Domain and user
$IdentityReference = New-Object System.Security.Principal.NTAccount("MyDomain\Bob")
$FileSystemRights = [System.Security.AccessControl.FileSystemRights]::Read
$InheritanceFlags = [System.Security.AccessControl.InheritanceFlags]::None
$PropagationFlags = [System.Security.AccessControl.PropagationFlags]::None
$AccessControlType =[System.Security.AccessControl.AccessControlType]::Allow

$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule (
  $IdentityReference,
  $FileSystemRights,
  $InheritanceFlags,
  $PropagationFlags,
  $AccessControlType
)

# change the file path
$CurrentACL = Get-ACL "C:\Reports\Test.ps1"
$CurrentACL.AddAccessRule($ACE)

Set-ACL -Path "C:\Scripts\Test.ps1" -AclObject $CurrentACL
#endregion

#region Hardware
Get-CimInstance -ClassName Win32_BIOS | 
    Export-Csv -NoTypeInformation -Path C:\Reports\Win32_Bios.csv

Get-CimInstance -ClassName Win32_BIOS | 
    Select-Object -ExpandProperty BIOSVersion

Get-CimInstance -ClassName Win32_BIOS | 
    Select-Object -Property @{
        Name = 'FormattedBIOSVersion'
        Expression = { $_.BIOSVersion -join ';' }
    } |
    Format-Table -Wrap

Get-CimInstance -ClassName Win32_BIOS | 
    Select-Object -Property Manufacturer,
        SerialNumber,
        ReleaseDate,
        SMBIOSBIOSVersion,
        SMBIOSMajorVersion,
        SMBIOSMinorVersion,
        @{
            Name = 'FormattedBIOSVersion';
            Expression = {$_.BIOSVersion -join ";"}
        }
#endregion



#region Getting member information
# Used to Easily Gather information for a command
# Get the CIM instance for Win32_ComputerSystem
Get-CimInstance -ClassName Win32_ComputerSystem | 
    # Now list each property and method of the object
    Get-Member | 
    # Just get the properties
    Where-Object MemberType -eq Property | 
    # Now loop through each object
    ForEach-Object {
        # Check if the defnintion matches specific strings
        if (($_.Definition -match '\[\]') -or ($_.Definition -match 'collec')) {
            # True - split each part of the property with a ';'
            "@{Name = '$($_.Name)'; Expression = {`$_.$($_.Name) -join ';'} },"
        } else {
            # False - just return the property name
            "$($_.Name),"
        }
    }
#endregion

#region Computer Information
Get-CimInstance -ClassName Win32_ComputerSystem | 
  Select-Object -Property Manufacturer,
    Model,
    DomainRole,
    Domain,
    WorkGroup,
    @{
      Name = 'FormattedRoles'; 
      Expression = {$_.Roles -join ";"} },
    TotalPhysicalMemory,
    SystemType,
    NumberOfProcessors,
    NumberOfLogicalProcessors,
    DnsHostName,
    CurrentTimeZone
#endregion

#region Processor
Get-CimInstance -ClassName Win32_Processor | 
  Select-Object -Property DeviceID,
    Status,
    AddressWidth,
    MaxClockSpeed,
    Caption,
    Description,
    Name,
    CurrentClockSpeed |
  Export-Csv -NoTypeInformation -Path C:\Reports\Win32_Processor.csv
#endregion