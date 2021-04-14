<#
SYNOPSIS
    This script is designed to delete a distribution list from Office 365 Exchange. This will only work on groups that have been migrated into the cloud.
NOTES
Generated On: 04/03/2021
Author: Matthew Heuer
#>
$DL = Read-Host "Enter the Distribution List's primary address"
$RITM= Read-Host "Enter the RITM number of the ticket"
$Date = Get-Date -Format FileDate

Try{
    $O365Username = Read-Host "Enter your Office 365 Admin Username"
    Connect-ExchangeOnline -UserPrincipalName $O365Username
    Write-Host "Connected to Exchange Online PowerShell."
} Catch {
    Write-Host "Unable to connect to Exchange Online. $($_.Exception.Message)."
    Exit
}

$Check = Get-DistributionGroup -Identity $DL
if ($Check) {
    Write-Host "Found $DL in Exchange Online" -ErrorAction Stop
} else {
    Write-Warning "$DL does not exist in Exchange Online"
    Exit
}

Try{
    Get-DistributionGroup -Identity $DL | Select-Object DisplayName,EmailAddresses,ManagedBy | Export-Csv -Path "\\dhw.wa.gov.au\corporatedata\is\tss\Support Centre\EntOps\Scripts\Exports\$RITM-$DL-$Date.csv" -NoTypeInformation
    $Member = Get-DistributionGroupMember -Identity $DL -ResultSize Unlimited | Select-Object Name,PrimarySMTPAddress
    Add-Content -Path "\\dhw.wa.gov.au\corporatedata\is\tss\Support Centre\EntOps\Scripts\Exports\$RITM-$DL-$Date.csv" -Value $Member
    Remove-DistributionGroup -Identity $DL
    Write-Host "$DL has been deleted from Exchange Online" 
} Catch {
    Write-Host "$DL failed to be deleted from Exchange Online"
}

