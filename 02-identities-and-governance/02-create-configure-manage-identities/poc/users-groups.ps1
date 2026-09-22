#!/usr/bin/env pwsh
# Module 2 — users, groups, membership (Azure PowerShell / Az.Resources).
#
# WARNING: Entra ID objects are tenant-wide. Default run is READ-ONLY.
# Writes require -Apply and are cleaned up at the end.
# Needs: User Administrator (or Groups Administrator) in the tenant.
[CmdletBinding()]
param(
    [switch]$Apply,
    [string]$Prefix = 'az104',
    [string]$UsageLocation = 'PH'
)

$ErrorActionPreference = 'Stop'

Write-Host '== Context =='
Get-AzContext | Select-Object Name, Tenant, Account | Format-List

Write-Host '== Users (first 15) =='
Get-AzADUser -First 15 |
    Select-Object DisplayName, UserPrincipalName, UserType |
    Format-Table

Write-Host '== Groups (first 15) =='
Get-AzADGroup -First 15 |
    Select-Object DisplayName, Id, MembershipRule |
    Format-Table

if (-not $Apply) {
    Write-Host @'

Read-only run complete. To create a demo user + group and then delete them:
  ./users-groups.ps1 -Apply

PowerShell advantage over the CLI here: New-AzADGroup can create a dynamic group directly
(-GroupType DynamicMembership -MembershipRule ... -MembershipRuleProcessingState On).
az ad group create cannot; it needs Graph via az rest. Dynamic membership requires P1.
'@
    return
}

# A UPN must use a verified domain. Take the tenant's default.
$defaultDomain = (Get-AzTenant | Select-Object -First 1).DefaultDomain
if (-not $defaultDomain) {
    throw 'Could not resolve a verified domain for this tenant.'
}

$upn = "$Prefix-demo-user-ps@$defaultDomain"
$groupName = "$Prefix-demo-group-ps"
$password = ConvertTo-SecureString -String ([System.Guid]::NewGuid().ToString() + 'Aa1!') -AsPlainText -Force

Write-Host "== Create user: $upn =="
$user = New-AzADUser `
    -DisplayName 'AZ104 Demo User (PS)' `
    -UserPrincipalName $upn `
    -MailNickname "$($Prefix)demouserps" `
    -Password $password `
    -AccountEnabled $true `
    -UsageLocation $UsageLocation `
    -ForceChangePasswordNextLogin
Write-Host "created user id: $($user.Id)"

Write-Host "== Create assigned security group: $groupName =="
$group = New-AzADGroup `
    -DisplayName $groupName `
    -MailNickname "$($Prefix)demogroupps" `
    -Description 'AZ-104 module 2 demo. Safe to delete.' `
    -SecurityEnabled
Write-Host "created group id: $($group.Id)"

Write-Host '== Add member, then prove membership =='
Add-AzADGroupMember -TargetGroupObjectId $group.Id -MemberObjectId $user.Id
Get-AzADGroupMember -GroupObjectId $group.Id |
    Select-Object DisplayName, Id |
    Format-Table

Write-Host '== Cleanup =='
Remove-AzADGroup -ObjectId $group.Id
Remove-AzADUser -ObjectId $user.Id
Write-Host 'deleted demo group and user.'
Write-Host 'Note: the user is soft-deleted for 30 days and can be restored.'
Write-Host '      A deleted security group cannot be restored the same way.'
