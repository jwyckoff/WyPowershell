$script = "C:\Documents\Code\Script.ps1"

# Create Self-signed Code Signing Certificate
New-SelfSignedCertificate `
    -DNSName "wyckoff.io" `
    -CertStoreLocation Cert:\CurrentUser\My `
    -Type CodeSigningCert `
    -Subject "Wyckoff PowerShell Code Signing Certificate"

# Retrieve the Code Signing Certificate
$certificate = (Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert)[0]

# Set the Code Signing Certificate for the PowerShell Script
Set-AuthenticodeSignature $script -Certificate $certificate

# Validate the Code Signing Certificate
Get-AuthenticodeSignature $script | Format-Table -AutoSize