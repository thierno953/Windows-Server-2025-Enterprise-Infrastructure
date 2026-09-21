#requires -Modules ActiveDirectory

[CmdletBinding()]
param(
    [switch]$Preview
)

Import-Module ActiveDirectory

$Root            = "C:\SysAdminToolkit\02-ActiveDirectory"
$CsvPath         = "$Root\Data\Users.csv"
$ReportDirectory = "$Root\Reports"
$LogDirectory    = "$Root\Logs"

$Domain   = Get-ADDomain
$DomainDN = $Domain.DistinguishedName
$BaseOU   = "OU=Diarabaka,$DomainDN"
$UsersOU  = "OU=Users,$BaseOU"

$DepartmentOUs = @{
    "IT"        = "OU=IT,$UsersOU"
    "HR"        = "OU=HR,$UsersOU"
    "Finance"   = "OU=Finance,$UsersOU"
    "Marketing" = "OU=Marketing,$UsersOU"
    "Sales"     = "OU=Sales,$UsersOU"
}

New-Item -Path $ReportDirectory -ItemType Directory -Force | Out-Null
New-Item -Path $LogDirectory -ItemType Directory -Force | Out-Null

$Timestamp  = Get-Date -Format "yyyyMMdd-HHmmss"
$ReportPath = "$ReportDirectory\Create-Users-$Timestamp.csv"
$LogPath    = "$LogDirectory\Create-Users-$Timestamp.log"

function Write-Log {
    param([string]$Message)
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message" |
        Add-Content -Path $LogPath
}

if (-not (Test-Path $CsvPath)) {
    Write-Host "[ERROR] CSV not found: $CsvPath" -ForegroundColor Red
    exit 1
}

foreach ($OU in $DepartmentOUs.Values) {
    if (-not (Get-ADOrganizationalUnit -Identity $OU -ErrorAction SilentlyContinue)) {
        Write-Host "[ERROR] Missing department OU: $OU" -ForegroundColor Red
        exit 1
    }
}

$Users = Import-Csv -Path $CsvPath -Delimiter ";"

$RequiredColumns = "FirstName","LastName","Username","Department","Title"
$CsvColumns = $Users[0].PSObject.Properties.Name

foreach ($Column in $RequiredColumns) {
    if ($Column -notin $CsvColumns) {
        Write-Host "[ERROR] Missing CSV column: $Column" -ForegroundColor Red
        exit 1
    }
}

$Results = foreach ($User in $Users) {
    $DisplayName = "$($User.FirstName) $($User.LastName)"

    if ([string]::IsNullOrWhiteSpace($User.Username)) {
        [PSCustomObject]@{
            Username=$User.Username; Name=$DisplayName; Department=$User.Department
            TargetOU=""; Status="FAILED"; Message="Username missing"
        }
        continue
    }

    if (-not $DepartmentOUs.ContainsKey($User.Department)) {
        [PSCustomObject]@{
            Username=$User.Username; Name=$DisplayName; Department=$User.Department
            TargetOU=""; Status="FAILED"; Message="Unknown department"
        }
        continue
    }

    $TargetOU = $DepartmentOUs[$User.Department]
    $Existing = Get-ADUser -Filter "SamAccountName -eq '$($User.Username)'" -ErrorAction SilentlyContinue

    [PSCustomObject]@{
        Username   = $User.Username
        Name       = $DisplayName
        Department = $User.Department
        TargetOU   = $TargetOU
        Status     = if ($Existing) { "EXISTS" } else { "READY" }
        Message    = if ($Existing) { "User already exists" } else { "User can be created" }
    }
}

$Results | Format-Table Username,Department,TargetOU,Status -AutoSize
$Results | Export-Csv -Path $ReportPath -NoTypeInformation -Encoding UTF8

if ($Preview) {
    Write-Host "PREVIEW ONLY - no change made." -ForegroundColor Yellow
    exit 0
}

if ($Results.Status -contains "FAILED") {
    Write-Host "[ERROR] Creation blocked because preview contains FAILED entries." -ForegroundColor Red
    exit 1
}

$Password = Read-Host "Temporary password" -AsSecureString

$FinalResults = foreach ($User in $Users) {
    $DisplayName = "$($User.FirstName) $($User.LastName)"
    $TargetOU = $DepartmentOUs[$User.Department]

    if (Get-ADUser -Filter "SamAccountName -eq '$($User.Username)'" -ErrorAction SilentlyContinue) {
        [PSCustomObject]@{Username=$User.Username;Department=$User.Department;TargetOU=$TargetOU;Status="EXISTS"}
        continue
    }

    try {
        New-ADUser `
            -Name $DisplayName `
            -GivenName $User.FirstName `
            -Surname $User.LastName `
            -SamAccountName $User.Username `
            -UserPrincipalName "$($User.Username)@$($Domain.DNSRoot)" `
            -DisplayName $DisplayName `
            -Department $User.Department `
            -Title $User.Title `
            -Path $TargetOU `
            -AccountPassword $Password `
            -Enabled $true `
            -ChangePasswordAtLogon $true `
            -ErrorAction Stop

        Write-Log "CREATED user=$($User.Username) ou=$TargetOU"
        [PSCustomObject]@{Username=$User.Username;Department=$User.Department;TargetOU=$TargetOU;Status="CREATED"}
    }
    catch {
        Write-Log "FAILED user=$($User.Username) error=$($_.Exception.Message)"
        [PSCustomObject]@{Username=$User.Username;Department=$User.Department;TargetOU=$TargetOU;Status="FAILED"}
    }
}

$FinalResults | Format-Table -AutoSize
$FinalResults | Export-Csv -Path $ReportPath -NoTypeInformation -Encoding UTF8