
Break

#region Listing Applications using CIM
Get-CimInstance -ClassName Win32_Product

#Save to a file
Get-CimInstance -ClassName Win32_Product |
    Export-Csv -Path "C:\Reports\AppsFromCIM_$(Get-Date -Format yyyyMMdd).csv" -NoTypeInformation
#endregion

# To compare file versions, check the script "CompareInstalledApps.ps1"

# Programs listed from registry can be found in this script "Listing Programs thru registry query.ps1"

#region Example of combining disparate types into common output
#Create Empty arrays
$A = @()
$headers = @()

# Get a random process
$A += Get-Process | Get-Random -Count 1 | Select-Object Name, Id, VirtualMemorySize
$headers += "Name", "ID", "VirtualMemorySize"

# Get a random service
$A += Get-Service | Get-Random -Count 1
$headers += $A |
    Get-Member -MemberType Properties -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Name

# Create a complete list of headers
$FullListOfHeaders = $headers | Select-Object -Unique | Sort-Object

# save information to test CSV file to review results
$A | 
    Select-Object -Property $FullListOfHeaders -ErrorAction SilentlyContinue | 
    Export-Csv -NoTypeInformation -Path C:\Reports\ArrayTest.csv

#endregion