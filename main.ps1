# Import the Active Directory module
Import-Module ActiveDirectory

# Get Password Policy settings from Active Directory
$passwordPolicy = Get-ADDefaultDomainPasswordPolicy

# Define the standard values
$standardMinPasswordLength = 8
$standardMaxPasswordAge = 42
$standardMinPasswordAge = 1
$standardComplexityEnabled = $true
$standardHistorySize = 24
$standardReversibleEncryption = $false

# Prepare the output
$output = @"
Password Policy Settings (Active Directory):
-------------------------------------------
Minimum Password Length: $($passwordPolicy.MinPasswordLength)
Maximum Password Age: $($passwordPolicy.MaxPasswordAge.Days) days
Minimum Password Age: $($passwordPolicy.MinPasswordAge.Days) days
Password Complexity Enabled: $($passwordPolicy.ComplexityEnabled)
Password History Length: $($passwordPolicy.PasswordHistoryCount)
Reversible Encryption: $($passwordPolicy.ReversibleEncryptionEnabled)
"@

# Check if the current settings comply with the standard values
$output += "Compliance Check:"
$output += "`n----------------------------"

if ($passwordPolicy.MinPasswordLength -lt $standardMinPasswordLength) {
    $output += "`nMinimum Password Length is less than standard ($standardMinPasswordLength)."
} else {
    $output += "`nMinimum Password Length is compliant."
}

if ($passwordPolicy.MaxPasswordAge.Days -gt $standardMaxPasswordAge) {
    $output += "`nMaximum Password Age is more than standard ($standardMaxPasswordAge days)."
} else {
    $output += "`nMaximum Password Age is compliant."
}

if ($passwordPolicy.MinPasswordAge.Days -lt $standardMinPasswordAge) {
    $output += "`nMinimum Password Age is less than standard ($standardMinPasswordAge days)."
} else {
    $output += "`nMinimum Password Age is compliant."
}

if (-not $passwordPolicy.ComplexityEnabled -eq $standardComplexityEnabled) {
    $output += "`nPassword Complexity is not enabled as per the standard."
} else {
    $output += "`nPassword Complexity is compliant."
}

if ($passwordPolicy.PasswordHistoryCount -lt $standardHistorySize) {
    $output += "`nPassword History Length is less than standard ($standardHistorySize)."
} else {
    $output += "`nPassword History Length is compliant."
}

if ($passwordPolicy.ReversibleEncryptionEnabled -eq $standardReversibleEncryption) {
    $output += "`nReversible Encryption is enabled, which is not compliant."
} else {
    $output += "`nReversible Encryption is compliant."
}

# Write the output to resultaten.txt
$output | Out-File -FilePath "resultaten.txt"
