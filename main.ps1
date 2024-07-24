# Import the Active Directory module
Import-Module ActiveDirectory

# Get Password Policy settings from Active Directory
$passwordPolicy = Get-ADDefaultDomainPasswordPolicy

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

# Write the output to resultaten.txt
$output | Out-File -FilePath "resultaten.txt"
