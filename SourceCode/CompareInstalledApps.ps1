[CmdletBinding()]
Param
(
    # Old File Full Name
    [Parameter(Mandatory=$true)]
    [ValidateScript({(Test-Path $_ -PathType Leaf)})]
    [string]$OldFile,

    # New File Full Name
    [Parameter(Mandatory=$true)]
    [ValidateScript({(Test-Path $_ -PathType Leaf)})]
    [string]$NewFile
)

Begin {
    #region This gets the old file and brings into memory.
    $OldFileData = Import-Csv -Path $OldFile
    $OldIdNumber = $OldFileData | Sort-Object 'IdentifyingNumber' | 
        Select-Object -ExpandProperty 'IdentifyingNumber'
    #endregion

    #region This gets the new file and brings into memory.
    $NewFileData = Import-Csv -Path $NewFile
    $NewIdNumber = $NewFileData | Sort-Object 'IdentifyingNumber' | 
        Select-Object -ExpandProperty 'IdentifyingNumber'
    #endregion
}
Process {
    #region We only want to compare (for the moment) what is Different
    $NewOrRemovedAppIds = Compare-Object -ReferenceObject $OldIdNumber -DifferenceObject $NewIdNumber -IncludeEqual
    $NewAppIds = $NewOrRemovedAppIds | Where-Object SideIndicator -EQ '=>'
    $RemovedAppIds = $NewOrRemovedAppIds | Where-Object SideIndicator -EQ '<='
    #endregion

    #region Checking for New Apps that were added since last we checked.
    $AllNewApps = @()
    foreach ($newApp in $NewAppIds) {
        $AllNewApps += $NewFileData | Where-Object 'IdentifyingNumber' -EQ $newApp.InputObject
    }
    Write-Host "`nRecently Installed Applications" -ForegroundColor Yellow
    $AllNewApps | Select-Object -Property Name, Version, Caption | Format-Table -AutoSize
    #endregion

    #region Checking for apps that have been uninstalled.
    $AllRemovedApps = @()
    foreach ($oldApp in $RemovedAppIds) {
        $AllRemovedApps += $OldFileData | Where-Object 'IdentifyingNumber' -EQ $OldApp.InputObject
    }
    Write-Host "`nRemoved Applications" -ForegroundColor Yellow
    $AllRemovedApps | Select-Object -Property Name, Version, Caption | Format-Table -AutoSize
    #endregion

    #region Checking for Changed File Versions
    Write-Host "`nChecking for Changed File Versions" -ForegroundColor Yellow
    foreach ($line in $OldFileData) {
        $SameApp = $NewFileData | Where-Object 'IdentifyingNumber' -EQ $line.IdentifyingNumber
        # Let's check if the versions match
        if (($SameApp.Version -notmatch $line.Version) -and ($SameApp -ne $null)) {
            Write-Host "This software, '$($line.Name)', was updated from version '$($line.Version)' to '$($SameApp.Version)'."
        }
    }
    #endregion
}
End { }
