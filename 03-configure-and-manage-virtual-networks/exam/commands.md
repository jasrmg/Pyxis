# Path 03 — Commands (Azure CLI ↔ Azure PowerShell)

Scope: **modules 1–3** (VNet/IP + NSG + DNS). Grows with peering, routes, LB.

## Module 1 — VNet and IP

| Job | Azure CLI | Azure PowerShell |
| --- | --- | --- |
| Create VNet + first subnet | `az network vnet create -g rg -n vnet-app --address-prefixes 10.0.0.0/16 --subnet-name snet-web --subnet-prefixes 10.0.1.0/24` | `New-AzVirtualNetwork` + `Add-AzVirtualNetworkSubnetConfig` + `Set-AzVirtualNetwork` |
| Add a subnet | `az network vnet subnet create -g rg --vnet-name vnet-app -n snet-data --address-prefixes 10.0.2.0/24` | `Add-AzVirtualNetworkSubnetConfig` then `Set-AzVirtualNetwork` |
| Standard public IP | `az network public-ip create -g rg -n pip --sku Standard --allocation-method Static` | `New-AzPublicIpAddress -Sku Standard -AllocationMethod Static` |
| Show VNet | `az network vnet show -g rg -n vnet-app` | `Get-AzVirtualNetwork -Name vnet-app -ResourceGroupName rg` |

**Trap:** `--sku Basic --allocation-method Dynamic` is the legacy public IP. New work is **Standard + Static**.

## Module 2 — NSG

| Job | Azure CLI | Azure PowerShell |
| --- | --- | --- |
| Create NSG | `az network nsg create -g rg -n nsg-web` | `New-AzNetworkSecurityGroup` |
| Inbound rule | `az network nsg rule create -g rg --nsg-name nsg-web -n allow-https --priority 100 --direction Inbound --access Allow --protocol Tcp --source-address-prefixes Internet --destination-port-ranges 443` | `Add-AzNetworkSecurityRuleConfig` then `Set-AzNetworkSecurityGroup` |
| Associate to subnet | `az network vnet subnet update -g rg --vnet-name vnet-app -n snet-web --network-security-group nsg-web` | `Set-AzVirtualNetworkSubnetConfig -NetworkSecurityGroup` then `Set-AzVirtualNetwork` |
| Associate to NIC | `az network nic update -g rg -n nic-web --network-security-group nsg-web` | `Set-AzNetworkInterface` |

**Trap:** lower **priority number** wins. Defaults cannot be deleted. Associate subnet or NIC, not the VM.

## Module 3 — Azure DNS

| Job | Azure CLI | Azure PowerShell |
| --- | --- | --- |
| Public zone | `az network dns zone create -g rg -n contoso.com` | `New-AzDnsZone` |
| A record | `az network dns record-set a add-record -g rg -z contoso.com -n www --ipv4-address 20.1.2.3` | `New-AzDnsRecordSet -RecordType A` |
| Alias A to PIP | `az network dns record-set a create -g rg -z contoso.com -n "@" --target-resource <pip-id>` | alias target on the record set |
| Private zone | `az network private-dns zone create -g rg -n private.contoso.com` | `New-AzPrivateDnsZone` |
| VNet link + auto-reg | `az network private-dns link vnet create -g rg -n link1 -z private.contoso.com -v vnet-app -e true` | `New-AzPrivateDnsVirtualNetworkLink -EnableRegistration` |

**Trap:** `dns` = public. `private-dns` = private. Azure DNS does **not** register the domain. CNAME ≠ apex; alias A/AAAA can be apex.