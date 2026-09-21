#requires -Modules ActiveDirectory

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [switch]$Preview
)

Import-Module ActiveDirectory -ErrorAction Stop

$Domain   = Get-ADDomain
$DomainDN = $Domain.DistinguishedName
$BaseOU   = "OU=Diarabaka,$DomainDN"

$OUPlan = @(
    @{ Name = "Diarabaka";              Path = $DomainDN;                         Description = "Diarabaka enterprise root OU" }

    @{ Name = "Users";                  Path = $BaseOU;                           Description = "Standard user accounts" }
    @{ Name = "Groups";                 Path = $BaseOU;                           Description = "Security groups" }
    @{ Name = "Computers";              Path = $BaseOU;                           Description = "Client computers" }
    @{ Name = "Servers";                Path = $BaseOU;                           Description = "Member servers" }
    @{ Name = "Admins";                 Path = $BaseOU;                           Description = "Dedicated administrative accounts" }
    @{ Name = "Service Accounts";       Path = $BaseOU;                           Description = "Service accounts" }

    @{ Name = "IT";                     Path = "OU=Users,$BaseOU";                Description = "IT users" }
    @{ Name = "HR";                     Path = "OU=Users,$BaseOU";                Description = "Human Resources users" }
    @{ Name = "Finance";                Path = "OU=Users,$BaseOU";                Description = "Finance users" }
    @{ Name = "Marketing";              Path = "OU=Users,$BaseOU";                Description = "Marketing users" }
    @{ Name = "Sales";                  Path = "OU=Users,$BaseOU";                Description = "Sales users" }

    @{ Name = "Department";             Path = "OU=Groups,$BaseOU";               Description = "Department security groups" }
    @{ Name = "Roles";                  Path = "OU=Groups,$BaseOU";               Description = "Role-based security groups" }
    @{ Name = "Resources";              Path = "OU=Groups,$BaseOU";               Description = "Resource permission groups" }

    @{ Name = "Workstations";           Path = "OU=Computers,$BaseOU";            Description = "Domain workstations" }

    @{ Name = "File Servers";           Path = "OU=Servers,$BaseOU";              Description = "File servers" }
    @{ Name = "Application Servers";    Path = "OU=Servers,$BaseOU";              Description = "Application servers" }
    @{ Name = "Infrastructure Servers"; Path = "OU=Servers,$BaseOU";              Description = "Infrastructure member servers" }
)

function Get-TargetDN {
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$Path
    )

    "OU=$Name,$Path"
}

function Test-OUExists {
    param(
        [Parameter(Mandatory)]
        [string]$DistinguishedName
    )

    try {
        $null = Get-ADOrganizationalUnit `
            -Identity $DistinguishedName `
            -ErrorAction Stop

        return $true
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
        return $false
    }
}

# ============================================================
# PRE-CHECK
# ============================================================

$Results = foreach ($OU in $OUPlan) {

    $TargetDN = Get-TargetDN `
        -Name $OU.Name `
        -Path $OU.Path

    $Exists = Test-OUExists `
        -DistinguishedName $TargetDN

    [PSCustomObject]@{
        Name   = $OU.Name
        Path   = $OU.Path
        DN     = $TargetDN
        Status = if ($Exists) { "EXISTS" } else { "READY" }
    }
}

$Results |
    Format-Table Name, Path, Status -AutoSize

if ($Preview) {
    Write-Host ""
    Write-Host "PREVIEW ONLY - no change made." -ForegroundColor Yellow
    return
}

# ============================================================
# CREATION
# ============================================================

foreach ($OU in $OUPlan) {

    $TargetDN = Get-TargetDN `
        -Name $OU.Name `
        -Path $OU.Path

    if (Test-OUExists -DistinguishedName $TargetDN) {
        Write-Host "[EXISTS]  $TargetDN" -ForegroundColor Yellow
        continue
    }

    try {

        if ($PSCmdlet.ShouldProcess($TargetDN, "Create OU")) {

            New-ADOrganizationalUnit `
                -Name $OU.Name `
                -Path $OU.Path `
                -Description $OU.Description `
                -ProtectedFromAccidentalDeletion $true `
                -ErrorAction Stop

            Write-Host "[CREATED] $TargetDN" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "[ERROR]   $TargetDN : $($_.Exception.Message)" `
            -ForegroundColor Red
    }
}