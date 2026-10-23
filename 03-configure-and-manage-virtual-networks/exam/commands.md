# Path 03 — Commands (Azure CLI ↔ Azure PowerShell)

Scope: **modules 1–6** (VNet/IP + NSG + DNS + peering + routes + LB). Grows with App Gateway / Watcher.

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

## Module 4 — VNet peering

| Job | Azure CLI | Azure PowerShell |
| --- | --- | --- |
| Peer A → B | `az network vnet peering create -g rg -n a-to-b --vnet-name vnet-a --remote-vnet vnet-b --allow-vnet-access` | `Add-AzVirtualNetworkPeering` |
| Peer B → A (required) | same, swap names | second `Add-AzVirtualNetworkPeering` |
| Hub allows gateway transit | add `--allow-gateway-transit` | `-AllowGatewayTransit` |
| Spoke uses hub gateway | add `--use-remote-gateways` | `-UseRemoteGateways` |
| Accept NVA-forwarded packets | add `--allow-forwarded-traffic` | `-AllowForwardedTraffic` |

**Trap:** two peering objects; both **Connected**. Non-overlapping CIDR. Not transitive. Hub = transit; spoke = remote gateway; spoke has no local gateway.

## Module 5 — Routes

| Job | Azure CLI | Azure PowerShell |
| --- | --- | --- |
| Route table | `az network route-table create -g rg -n rt-app` | `New-AzRouteTable` |
| UDR | `az network route-table route create -g rg --route-table-name rt-app -n to-nva --address-prefix 0.0.0.0/0 --next-hop-type VirtualAppliance --next-hop-ip-address 10.0.100.4` | `Add-AzRouteConfig` |
| Associate to subnet | `az network vnet subnet update -g rg --vnet-name vnet-app -n snet-web --route-table rt-app` | `Set-AzVirtualNetworkSubnetConfig -RouteTable` |
| NVA IP forwarding | `az network nic update -g rg -n nic-nva --ip-forwarding true` | `Set-AzNetworkInterface -EnableIPForwarding` |

**Trap:** table → **subnet**, not NIC. Longest prefix first; same prefix UDR > BGP > system. NVA other subnet; forwarding NIC **and** OS. Next hop **None** = drop. No UDR next hop “peering.”

## Module 6 — Load Balancer

| Job | Azure CLI | Azure PowerShell |
| --- | --- | --- |
| Standard PIP | `az network public-ip create -g rg -n pip-lb --sku Standard --allocation-method Static` | `New-AzPublicIpAddress -Sku Standard` |
| Public LB | `az network lb create -g rg -n lb --sku Standard --public-ip-address pip-lb --frontend-ip-name fe --backend-pool-name be` | `New-AzLoadBalancer -Sku Standard` |
| Internal LB | `az network lb create ... --vnet-name vnet --subnet snet` (no PIP) | frontend subnet, not PIP |
| Probe | `az network lb probe create -g rg --lb-name lb -n probe --protocol Http --port 80 --path /` | `Add-AzLoadBalancerProbeConfig` |
| Rule | `az network lb rule create ... --frontend-port 80 --backend-port 80 --probe-name probe` | `Add-AzLoadBalancerRuleConfig` |
| Add NIC to pool | `az network nic ip-config address-pool add ... --address-pool be` | backend pool NIC IP config |

**Trap:** L4 not L7. Standard + Standard PIP. Closed until NSG. ILB = private frontend. HTTP probe = **200**. Probe source `168.63.129.16`. Basic SKU retired.