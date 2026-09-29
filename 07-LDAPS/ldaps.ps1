# ============================================================
# LDAPS Validation Script
# Windows Server 2025 Enterprise Infrastructure Lab
# ============================================================

$ComputerName = "WIN25-DC01.diarabaka.com"
$Port = 636

try {

    Write-Host "Connecting to $ComputerName on port $Port..." -ForegroundColor Cyan

    # Create TCP connection
    $TcpClient = New-Object System.Net.Sockets.TcpClient
    $TcpClient.Connect($ComputerName, $Port)

    # Create SSL/TLS stream
    $SslStream = New-Object System.Net.Security.SslStream(
        $TcpClient.GetStream(),
        $false,
        { $true }
    )

    # Perform SSL/TLS authentication
    $SslStream.AuthenticateAsClient($ComputerName)

    # Retrieve the server certificate
    $Certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2(
        $SslStream.RemoteCertificate
    )

    Write-Host ""
    Write-Host "========== LDAPS Certificate ==========" -ForegroundColor Green

    Write-Host ("Subject       : {0}" -f $Certificate.Subject)
    Write-Host ("Issuer        : {0}" -f $Certificate.Issuer)
    Write-Host ("Valid From    : {0}" -f $Certificate.NotBefore)
    Write-Host ("Valid Until   : {0}" -f $Certificate.NotAfter)
    Write-Host ("Thumbprint    : {0}" -f $Certificate.Thumbprint)
    Write-Host ("Serial Number : {0}" -f $Certificate.SerialNumber)

    Write-Host ""
    Write-Host "LDAPS validation completed successfully." -ForegroundColor Green

    # Cleanup
    $SslStream.Close()
    $TcpClient.Close()

}
catch {

    Write-Host ""
    Write-Host "LDAPS validation failed." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Yellow

}