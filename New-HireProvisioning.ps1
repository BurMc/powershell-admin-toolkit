param (
    [Parameter(Mandatory)]
    [string]$FirstName,

    [Parameter(Mandatory)]
    [string]$LastName,

    [Parameter(Mandatory)]
    [string]$Department,

    [Parameter(Mandatory)]
    [string]$Title,

    [Parameter(Mandatory)]
    [string]$Manager

)

# Build standard variables
$FullName = "$FirstName $LastName"
$SamAccount = ($FirstName.Substring(0,1) + $LastName).ToLower()
$UPN = "$SamAccount@yourdomain.com"
$DefaultPass = ConvertTo-SecureString "Welcome@2024!" -AsPlainText -Force
$OU = "OU=Users, OU=$Department,DC=yourdomain,DC=com"

# Create the AD user
New-ADUser `
    -Name $FullName `
    -GivenName $FirstName `
    -Surname $LastName `
    -SamAccountName $SamAccount `
    -UserPrincipalName $UPN `
    -Deparment $Department `
    -Title $Title `
    -Manager $Manager `
    -Path $OU `
    AccountPassword $DefaultPass `
    -Enable $true `

    Write-Host "User $FullName created successfully." -ForgeroundColor Green
    Write-Host "Username: $SamAccount" -ForgeroundColor Cyan
    Write-Host "UPN: $UPN" -ForegroundColor Cyan