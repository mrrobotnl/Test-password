# Import the Active Directory module
Import-Module ActiveDirectory

# Import the AzureAD module
Import-Module AzureAD

# Define the standard values
$standardMinPasswordLength = 8
$standardMaxPasswordAge = 42
$standardMinPasswordAge = 1
$standardComplexityEnabled = $true
$standardHistorySize = 24
$standardReversibleEncryption = $false
$standardMFAEnabledPercentage = 100  # Define the standard MFA enabled percentage, here assumed 100%

# Initialize MFA compliance check variables
$mfaEnabledPercentage = 0
$azureADConnection = $false
$mfaCheckResult = "Azure AD MFA check not performed due to connection issue."

# Attempt to connect to Azure AD
try {
    Connect-AzureAD -ErrorAction Stop
    $azureADConnection = $true
} catch {
    Write-Host "Could not connect to Azure AD. Proceeding without MFA check."
}

# Get Password Policy settings from Active Directory
$passwordPolicy = Get-ADDefaultDomainPasswordPolicy

# If connected to Azure AD, perform MFA check
if ($azureADConnection) {
    $mfaUsers = Get-AzureADUser -All $true | Where-Object { (Get-AzureADUserMFAState -ObjectId $_.ObjectId).State -eq "Enabled" }
    $totalUsers = (Get-AzureADUser -All $true).Count
    $mfaEnabledCount = $mfaUsers.Count
    $mfaEnabledPercentage = ($mfaEnabledCount / $totalUsers) * 100

    if ($mfaEnabledPercentage -lt $standardMFAEnabledPercentage) {
        $mfaCheckResult = "MFA Enabled Percentage is less than standard ($standardMFAEnabledPercentage%)."
    } else {
        $mfaCheckResult = "MFA Enabled Percentage is compliant."
    }
}

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

$output += "`nMFA Compliance Check:"
$output += "`n----------------------------"
$output += "`n$mfaCheckResult"

# Write the output to resultaten.txt
$output | Out-File -FilePath "resultaten.txt"
