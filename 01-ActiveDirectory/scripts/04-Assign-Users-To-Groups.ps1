#requires -Modules ActiveDirectory

[CmdletBinding()]
param([switch]$Preview)

Import-Module ActiveDirectory

$Domain   = Get-ADDomain
$DomainDN = $Domain.DistinguishedName
$BaseOU   = "OU=Diarabaka,$DomainDN"
$UsersOU  = "OU=Users,$BaseOU"
$DeptOU   = "OU=Department,OU=Groups,$BaseOU"

$DepartmentGroups = @{
    "IT"        = "GG-IT"
    "HR"        = "GG-HR"
    "Finance"   = "GG-Finance"
    "Marketing" = "GG-Marketing"
    "Sales"     = "GG-Sales"
}

$Users = @(
    Get-ADUser `
        -SearchBase $UsersOU `
        -SearchScope Subtree `
        -Filter * `
        -Properties Department `
        -ErrorAction Stop
)

$Results = foreach ($User in $Users) {
    $Department = $User.Department

    if ([string]::IsNullOrWhiteSpace($Department)) {
        [PSCustomObject]@{User=$User.SamAccountName;Department="";Group="";Status="SKIPPED";Message="No department"}
        continue
    }

    if (-not $DepartmentGroups.ContainsKey($Department)) {
        [PSCustomObject]@{User=$User.SamAccountName;Department=$Department;Group="";Status="SKIPPED";Message="No mapping"}
        continue
    }

    $GroupName = $DepartmentGroups[$Department]
    $Group = Get-ADGroup `
        -Filter "SamAccountName -eq '$GroupName'" `
        -SearchBase $DeptOU `
        -ErrorAction SilentlyContinue

    if (-not $Group) {
        [PSCustomObject]@{User=$User.SamAccountName;Department=$Department;Group=$GroupName;Status="ERROR";Message="Group missing"}
        continue
    }

    $IsMember = Get-ADGroupMember -Identity $Group -ErrorAction SilentlyContinue |
        Where-Object SamAccountName -eq $User.SamAccountName

    [PSCustomObject]@{
        User       = $User.SamAccountName
        Department = $Department
        Group      = $GroupName
        Status     = if ($IsMember) { "EXISTS" } else { "READY" }
        Message    = if ($IsMember) { "Already member" } else { "Can be added" }
    }
}

$Results | Sort-Object Group,User | Format-Table -AutoSize

if ($Preview) {
    Write-Host "PREVIEW ONLY - no change made." -ForegroundColor Yellow
    return
}

foreach ($Result in $Results | Where-Object Status -eq "READY") {
    try {
        Add-ADGroupMember -Identity $Result.Group -Members $Result.User -ErrorAction Stop
        Write-Host "[ADDED] $($Result.User) -> $($Result.Group)" -ForegroundColor Green
    }
    catch {
        Write-Host "[ERROR] $($Result.User) -> $($Result.Group): $($_.Exception.Message)" -ForegroundColor Red
    }
}