# Path 05 — Commands (Azure CLI ↔ Azure PowerShell)

Scope: **module 1** (create a VM, deallocate, resize). Grows with availability, App Service, and containers.

## Module 1 — Virtual machines

| Job | Azure CLI | Azure PowerShell |
| --- | --- | --- |
| Ubuntu VM, SSH key | `az vm create -g rg -n vm-web01 --image Ubuntu2204 --size Standard_D2s_v5 --admin-username azureuser --generate-ssh-keys` | `New-AzVM -Name vm-web01 -Image Ubuntu2204 -Size Standard_D2s_v5` |
| Deallocate (stops compute billing) | `az vm deallocate -g rg -n vm-web01` | `Stop-AzVM -Name vm-web01 -Force` |
| Resize after deallocate | `az vm resize -g rg -n vm-web01 --size Standard_D4s_v5` | `Resize-AzVM` is not the cmdlet. Update the size with `Get-AzVM` and `Update-AzVM` |
| Start | `az vm start -g rg -n vm-web01` | `Start-AzVM -Name vm-web01` |
| Export the deployment as ARM | Portal: VM **Automation** → **Export template**. CLI: `az deployment group export` | `Save-AzResourceGroupDeploymentTemplate` is not how you export a live VM. Use the portal export, then `az bicep decompile` |

**Trap:** A running resize reboots the VM and only works when the new size is on the same hardware cluster. Deallocate to pick any size in the region. Disks are still billed while the VM is deallocated. The temporary disk is not. Terraform is in the Learn unit and is not on this exam.
