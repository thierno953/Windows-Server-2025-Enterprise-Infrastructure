#requires -Modules ActiveDirectory

[CmdletBinding()]
param([switch]$Preview)

Import-Module ActiveDirectory

$Domain   = Get-ADDomain
$DomainDN = $Domain.DistinguishedName
$BaseOU   = "OU=Diarabaka,$DomainDN"
$GroupsOU = "OU=Groups,$BaseOU"

$GroupOUs = @{
    Department = "OU=Department,$GroupsOU"
    Roles      = "OU=Roles,$GroupsOU"
    Resources  = "OU=Resources,$GroupsOU"
}

$Groups = @(
    @{ Name="GG-IT";          Type="Department"; Description="IT Department" },
    @{ Name="GG-HR";          Type="Department"; Description="Human Resources Department" },
    @{ Name="GG-Finance";     Type="Department"; Description="Finance Department" },
    @{ Name="GG-Marketing";   Type="Department"; Description="Marketing Department" },
    @{ Name="GG-Sales";       Type="Department"; Description="Sales Department" },

    @{ Name="GG-IT-Admins";    Type="Roles"; Description="IT administrative role" },
    @{ Name="GG-IT-Helpdesk";  Type="Roles"; Description="IT helpdesk role" },
    @{ Name="GG-IT-Network";   Type="Roles"; Description="Network administration role" },
    @{ Name="GG-IT-Security";  Type="Roles"; Description="Security administration role" },
    @{ Name="GG-IT-Cloud";     Type="Roles"; Description="Cloud administration role" }
)

foreach ($OU in $GroupOUs.Values) {
    if (-not (Get-ADOrganizationalUnit -Identity $OU -ErrorAction SilentlyContinue)) {
        Write-Host "[ERROR] Missing OU: $OU" -ForegroundColor Red
        exit 1
    }
}

$Results = foreach ($Group in $Groups) {
    $TargetOU = $GroupOUs[$Group.Type]
    $Existing = Get-ADGroup -Filter "SamAccountName -eq '$($Group.Name)'" -ErrorAction SilentlyContinue

    [PSCustomObject]@{
        Name     = $Group.Name
        Type     = $Group.Type
        TargetOU = $TargetOU
        Status   = if ($Existing) { "EXISTS" } else { "READY" }
    }
}

$Results | Format-Table -AutoSize

if ($Preview) {
    Write-Host "PREVIEW ONLY - no change made." -ForegroundColor Yellow
    return
}

foreach ($Group in $Groups) {
    $TargetOU = $GroupOUs[$Group.Type]

    if (Get-ADGroup -Filter "SamAccountName -eq '$($Group.Name)'" -ErrorAction SilentlyContinue) {
        Write-Host "[EXISTS] $($Group.Name)" -ForegroundColor Yellow
        continue
    }

    try {
        New-ADGroup `
            -Name $Group.Name `
            -SamAccountName $Group.Name `
            -GroupCategory Security `
            -GroupScope Global `
            -DisplayName $Group.Name `
            -Description $Group.Description `
            -Path $TargetOU `
            -ErrorAction Stop

        Write-Host "[CREATED] $($Group.Name) -> $TargetOU" -ForegroundColor Green
    }
    catch {
        Write-Host "[ERROR] $($Group.Name): $($_.Exception.Message)" -ForegroundColor Red
    }
}