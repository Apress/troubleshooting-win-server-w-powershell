
# Map drive to HKEY_USERS
$null = New-PSDrive -Name HKU -PSProvider Registry -Root Registry::HKEY_USERS

# Static paths, regardless of user
$softwareKeys = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\',
    'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\',
    'HKLM:\SOFTWARE\Classes\Installer\Products\'
)

# Find all local users on the computer
$allLocalUsers = Get-ChildItem -Path HKU: | 
    where {$_.Name -match 'S-\d-\d+-(\d+-){1,14}\d+$' } | 
    Select-Object -ExpandProperty PSChildName

# Add each user's registry keys to list of registry keys to check
foreach ($LU in $allLocalUsers) {
    $softwareKeys += "HKU:\$LU\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\"
    $softwareKeys += "HKU:\$LU\SOFTWARE\Microsoft\Installer\Products\"
}

# Loop through each key and check for programs
$allPrograms = @()
foreach ($regKey in $softwareKeys) {
    $allPrograms += Get-ChildItem -Path $regKey
}

# Getting the details for each program found
$allDetails = @()
$itemHeaders = @()
foreach ($regItem in $allPrograms) {
    # replace Full Path with Relative Path
    $relPath = ($regItem.Name -replace 'HKEY_LOCAL_MACHINE','HKLM:') -replace 'HKEY_USERS','HKU:'
    $allDetails += Get-ItemProperty -Path $relPath
    $itemHeaders += Get-ItemProperty -Path $relPath | 
        Get-Member -MemberType Properties -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty Name
}

$FullListOfHeaders = $itemHeaders | Select-Object -Unique | Sort-Object

$allDetails | 
    Select-Object -Property $FullListOfHeaders -ErrorAction SilentlyContinue | 
    Export-Csv -NoTypeInformation -Path "C:\Reports\InstalledAppsRegistry_$(Get-Date -Format yyyyMMdd).csv"
