# Path 03 — Commands (Azure CLI ↔ Azure PowerShell)

Scope: **module 1** (VNet, subnet, public/private IP). Grows with NSG, DNS, peering, routes, LB.

| Job | Azure CLI | Azure PowerShell |
| --- | --- | --- |
| Create VNet + first subnet | `az network vnet create -g rg -n vnet-app --address-prefixes 10.0.0.0/16 --subnet-name snet-web --subnet-prefixes 10.0.1.0/24` | `New-AzVirtualNetwork` + `Add-AzVirtualNetworkSubnetConfig` + `Set-AzVirtualNetwork` |
| Add a subnet | `az network vnet subnet create -g rg --vnet-name vnet-app -n snet-data --address-prefixes 10.0.2.0/24` | `Add-AzVirtualNetworkSubnetConfig` then `Set-AzVirtualNetwork` |
| Standard public IP | `az network public-ip create -g rg -n pip --sku Standard --allocation-method Static` | `New-AzPublicIpAddress -Sku Standard -AllocationMethod Static` |
| Show VNet | `az network vnet show -g rg -n vnet-app` | `Get-AzVirtualNetwork -Name vnet-app -ResourceGroupName rg` |

**Trap:** `--sku Basic --allocation-method Dynamic` is the legacy public IP. New work is **Standard + Static**.
