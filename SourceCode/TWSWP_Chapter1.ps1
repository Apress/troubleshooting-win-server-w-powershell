
Break

#region Using Write-Host with InformationVariable
# This displays something to your screen and saves that to a variable
Write-Host "Found a process called '$(Get-Process pow* | Select-Object -ExpandProperty Name)'" -InformationVariable ProcsThatStartWithPow

# This will re-display your display by calling that variable
$ProcsThatStartWithPow
#endregion

#region Example of a Synopsis
<#
    .SYNOPSIS
        This function updates titles in Active Directory
    .DESCRIPTION
        Using this function will update the title of a user in Active Directory
    .PARAMETER  UserName
        The username parameter identifies the record in Active Directory to be updated
    .PARAMETER  Title
        The title parameter corresponds to the title attribute in Active Directory.
    .EXAMPLE
        Update-TSADUserTitle -UserName 'user' -Title "PowerShell Wizard"
    .EXAMPLE
        Update-TSADUserTitle 'user' "PowerShell User"
    .INPUTS
        System.String
    .OUTPUTS
        System.String
    .NOTES
        Use this function to update the title of an Active Directory user
    .LINK
        about_functions_advanced
    .LINK
        about_comment_based_help
#>
#endregion