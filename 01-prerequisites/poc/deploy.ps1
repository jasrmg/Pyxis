#!/usr/bin/env pwsh
# AZ-104 exam path: Azure PowerShell + ARM JSON (Learn module 2) or Bicep.
# Default is -WhatIf. Pass -Apply only in a sandbox / dedicated RG.
[CmdletBinding()]
param(
    [switch]$Apply,
    [ValidateSet('arm', 'bicep')]
    [string]$Template = 'arm',
    [string]$ResourceGroupName = 'rg-pyxis-dev-prereq',
    [string]$Location = 'eastus'
)

$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

Write-Host '== Identity =='
Get-AzContext | Format-List

Write-Host @'

== Cloud Shell operator notes ==
- Host is a temporary Linux container. Idle timeout is 20 minutes of no interactive activity.
- Persistent files need an Azure Files share. $HOME is a 5 GB image on that share.
- clouddrive is the share mounted at $HOME/clouddrive.
- Ephemeral sessions discard files when the session ends.
- Do not park production secrets in $HOME on a storage account the subscription can read.
- Long, quiet jobs do not belong here. Use a workstation or a pipeline.
'@

$templateFile = if ($Template -eq 'arm') { 'azuredeploy.json' } else { 'main.bicep' }
$parameterFile = 'azuredeploy.parameters.json'

Write-Host '== Resource group (idempotent) =='
New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Force | Format-Table

Write-Host "== what-if ($templateFile, Incremental) =="
New-AzResourceGroupDeployment `
    -ResourceGroupName $ResourceGroupName `
    -TemplateFile $templateFile `
    -TemplateParameterFile $parameterFile `
    -Mode Incremental `
    -WhatIf

if ($Apply) {
    Write-Host '== -Apply — deploying (sandbox only, Incremental mode) =='
    $deployment = New-AzResourceGroupDeployment `
        -Name prereq-storage `
        -ResourceGroupName $ResourceGroupName `
        -TemplateFile $templateFile `
        -TemplateParameterFile $parameterFile `
        -Mode Incremental

    $deployment | Format-List
    Write-Host 'Outputs:'
    $deployment.Outputs | Format-List

    Write-Host "Export this RG as ARM JSON (exam skill): Export-AzResourceGroup -ResourceGroupName $ResourceGroupName"
    Write-Host 'Convert ARM JSON to Bicep (exam skill): az bicep decompile --file azuredeploy.json'
}
else {
    Write-Host 'what-if complete. Sandbox deploy: ./deploy.ps1 -Apply'
    Write-Host 'Bicep instead of ARM JSON: ./deploy.ps1 -Template bicep -Apply'
    Write-Host 'Do not use -Mode Complete on a shared resource group.'
}
