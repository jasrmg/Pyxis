# Path 05 — Commands (Azure CLI ↔ Azure PowerShell)

Scope: **modules 1–2** (create a VM, availability sets, scale sets). Grows with App Service and containers.

## Module 1 — Virtual machines

| Job | Azure CLI | Azure PowerShell |
| --- | --- | --- |
| Ubuntu VM, SSH key | `az vm create -g rg -n vm-web01 --image Ubuntu2204 --size Standard_D2s_v5 --admin-username azureuser --generate-ssh-keys` | `New-AzVM -Name vm-web01 -Image Ubuntu2204 -Size Standard_D2s_v5` |
| Deallocate (stops compute billing) | `az vm deallocate -g rg -n vm-web01` | `Stop-AzVM -Name vm-web01 -Force` |
| Resize after deallocate | `az vm resize -g rg -n vm-web01 --size Standard_D4s_v5` | `Resize-AzVM` is not the cmdlet. Update the size with `Get-AzVM` and `Update-AzVM` |
| Start | `az vm start -g rg -n vm-web01` | `Start-AzVM -Name vm-web01` |
| Export the deployment as ARM | Portal: VM **Automation** → **Export template**. CLI: `az deployment group export` | `Save-AzResourceGroupDeploymentTemplate` is not how you export a live VM. Use the portal export, then `az bicep decompile` |

**Trap:** A running resize reboots the VM and only works when the new size is on the same hardware cluster. Deallocate to pick any size in the region. Disks are still billed while the VM is deallocated. The temporary disk is not. Terraform is in the Learn unit and is not on this exam.

## Module 2 — Availability

| Job | Azure CLI | Azure PowerShell |
| --- | --- | --- |
| Availability set, 2 fault domains, 5 update domains | `az vm availability-set create -g rg -n avset-web -l eastus --platform-fault-domain-count 2 --platform-update-domain-count 5` | `New-AzAvailabilitySet -Name avset-web -PlatformFaultDomainCount 2 -PlatformUpdateDomainCount 5 -Sku Aligned` |
| VM in that set | `az vm create -g rg -n vm-web01 --image Ubuntu2204 --availability-set avset-web --generate-ssh-keys` | `New-AzVM` with `-AvailabilitySetId` |
| VM in a zone | `az vm create ... --zone 1` | `-Zone 1` |
| Flexible scale set across zones | `az vmss create -g rg -n vmss-web --image Ubuntu2204 --orchestration-mode Flexible --zones 1 2 3 --instance-count 2` | `New-AzVmss` with `-OrchestrationMode Flexible` |

**Trap:** Do not pass `--availability-set` and `--zone` on the same VM. Update domain count is **5** by default, **20** at most, and it cannot be edited. A running VM cannot be added to a set. Fixed spreading fails without five fault domains. Autoscale changes the instance count, not the size, and it stops at the maximum.
