#requires -Modules ActiveDirectory

[CmdletBinding()]
param(

    [Parameter(Mandatory)]
    [ValidateSet(
        "ResetPassword",
        "Unlock",
        "Disable",
        "Enable",
        "ExpirePassword",
        "UserInfo"
    )]
    [string]$Action,

    [Parameter(Mandatory)]
    [string]$Username
)

Import-Module ActiveDirectory

# ============================================================
# USER VALIDATION
# ============================================================

try {

    $User = Get-ADUser `
        -Identity $Username `
        -Properties `
            Enabled,
            LockedOut,
            PasswordExpired,
            PasswordLastSet,
            AccountExpirationDate,
            Department `
        -ErrorAction Stop
}
catch {

    Write-Host `
        "[ERROR] User not found: $Username" `
        -ForegroundColor Red

    exit 1
}

Write-Host ""
Write-Host "========================================" `
    -ForegroundColor Cyan

Write-Host "       HELPDESK USER MANAGEMENT" `
    -ForegroundColor Cyan

Write-Host "========================================" `
    -ForegroundColor Cyan

Write-Host ""
Write-Host "User   : $($User.SamAccountName)"
Write-Host "Name   : $($User.Name)"
Write-Host "Action : $Action"
Write-Host ""

# ============================================================
# ACTIONS
# ============================================================

switch ($Action) {

    # --------------------------------------------------------
    # USER INFORMATION
    # --------------------------------------------------------

    "UserInfo" {

        try {

            Get-ADUser `
                -Identity $Username `
                -Properties `
                    Enabled,
                    LockedOut,
                    PasswordExpired,
                    PasswordLastSet,
                    AccountExpirationDate,
                    Department `
                -ErrorAction Stop |
                Select-Object `
                    Name,
                    SamAccountName,
                    Enabled,
                    LockedOut,
                    PasswordExpired,
                    PasswordLastSet,
                    AccountExpirationDate,
                    Department
        }
        catch {

            Write-Host `
                "[ERROR] Unable to retrieve user information: $($_.Exception.Message)" `
                -ForegroundColor Red

            exit 1
        }
    }

    # --------------------------------------------------------
    # UNLOCK ACCOUNT
    # --------------------------------------------------------

    "Unlock" {

        try {

            Unlock-ADAccount `
                -Identity $Username `
                -ErrorAction Stop

            Write-Host `
                "[OK] Account unlocked." `
                -ForegroundColor Green
        }
        catch {

            Write-Host `
                "[ERROR] Unable to unlock account: $($_.Exception.Message)" `
                -ForegroundColor Red

            exit 1
        }
    }

    # --------------------------------------------------------
    # DISABLE ACCOUNT
    # --------------------------------------------------------

    "Disable" {

        try {

            Disable-ADAccount `
                -Identity $Username `
                -ErrorAction Stop

            Write-Host `
                "[OK] Account disabled." `
                -ForegroundColor Green
        }
        catch {

            Write-Host `
                "[ERROR] Unable to disable account: $($_.Exception.Message)" `
                -ForegroundColor Red

            exit 1
        }
    }

    # --------------------------------------------------------
    # ENABLE ACCOUNT
    # --------------------------------------------------------

    "Enable" {

        try {

            Enable-ADAccount `
                -Identity $Username `
                -ErrorAction Stop

            Write-Host `
                "[OK] Account enabled." `
                -ForegroundColor Green
        }
        catch {

            Write-Host `
                "[ERROR] Unable to enable account: $($_.Exception.Message)" `
                -ForegroundColor Red

            exit 1
        }
    }

    # --------------------------------------------------------
    # RESET PASSWORD
    # --------------------------------------------------------

    "ResetPassword" {

        Write-Host `
            "Enter a temporary password." `
            -ForegroundColor Yellow

        Write-Host `
            "The user will be required to change it at next logon." `
            -ForegroundColor Yellow

        Write-Host ""

        $Password = Read-Host `
            "Temporary password" `
            -AsSecureString

        try {

            Set-ADAccountPassword `
                -Identity $Username `
                -Reset `
                -NewPassword $Password `
                -ErrorAction Stop

            Set-ADUser `
                -Identity $Username `
                -ChangePasswordAtLogon $true `
                -ErrorAction Stop

            Write-Host ""
            Write-Host `
                "[OK] Password reset successfully." `
                -ForegroundColor Green

            Write-Host `
                "[OK] User must change password at next logon." `
                -ForegroundColor Green
        }
        catch {

            Write-Host ""
            Write-Host `
                "[ERROR] Password reset failed: $($_.Exception.Message)" `
                -ForegroundColor Red

            exit 1
        }
    }

    # --------------------------------------------------------
    # FORCE PASSWORD CHANGE
    # --------------------------------------------------------

    "ExpirePassword" {

        try {

            Set-ADUser `
                -Identity $Username `
                -ChangePasswordAtLogon $true `
                -ErrorAction Stop

            Write-Host `
                "[OK] Password marked for change at next logon." `
                -ForegroundColor Green
        }
        catch {

            Write-Host `
                "[ERROR] Unable to force password change: $($_.Exception.Message)" `
                -ForegroundColor Red

            exit 1
        }
    }
}