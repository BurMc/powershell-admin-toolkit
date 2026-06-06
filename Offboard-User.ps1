param (
    [Parameter(Mandatory)]
    [string]$SamAccountName,

    [string]$DisabledOU = "OU=Disabled,DC=yourdomain,DC=com",

    [string]$LogPath = "C:\Logs\Offboarding"
)

# Verify user exists before doing anything
$User = Get-ADUser -Identity $SamAccountName -Properties MemberOf, DisplayName -ErrorAction Stop

$Timestamp  = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DateStamp  = Get-Date -Format "yyyyMMdd"
$LogFile    = "$LogPath\Offboard_$DateStamp.log"
$Technician = $env:USERNAME

# Ensure log directory exists
if (-not (Test-Path $LogPath)) {
    New-Item -ItemType Directory -Path $LogPath | Out-Null
}

function Write-Log {
    param ([string]$Message)
    $Entry = "[$Timestamp] [$Technician] $Message"
    Add-Content -Path $LogFile -Value $Entry
    Write-Host $Entry
}

Write-Log "--- Offboarding started for: $SamAccountName ($($User.DisplayName)) ---"

# Disable the account
Disable-ADAccount -Identity $SamAccountName
Write-Log "Account disabled: $SamAccountName"
Write-Host "Account disabled." -ForegroundColor Yellow

# Strip all group memberships except Domain Users (primary group — cannot be removed)
$Groups = $User.MemberOf
if ($Groups.Count -gt 0) {
    foreach ($Group in $Groups) {
        Remove-ADGroupMember -Identity $Group -Members $SamAccountName -Confirm:$false
        Write-Log "Removed from group: $Group"
    }
    Write-Host "All group memberships removed." -ForegroundColor Yellow
} else {
    Write-Log "No additional group memberships found."
    Write-Host "No group memberships to remove." -ForegroundColor Cyan
}

# Move account to Disabled OU
Move-ADObject -Identity $User.DistinguishedName -TargetPath $DisabledOU
Write-Log "Account moved to: $DisabledOU"
Write-Host "Account moved to Disabled OU." -ForegroundColor Yellow

Write-Log "--- Offboarding complete for: $SamAccountName ---"
Write-Host "Offboarding complete. Log saved to: $LogFile" -ForegroundColor Green
