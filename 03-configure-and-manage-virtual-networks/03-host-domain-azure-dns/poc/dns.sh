#!/usr/bin/env bash
# Module 3 — public DNS zone + www A record. Default is a dry print.
set -euo pipefail

RG="${RG:-rg-az104-dns}"
LOC="${LOC:-eastus}"
ZONE="${ZONE:-az104.example}"

echo "== Plan =="
echo "RG=$RG location=$LOC"
echo "Public DNS zone $ZONE (SOA + NS created with the zone)"
echo "  A  www.$ZONE -> 20.1.2.3"
echo "Azure DNS does not register the domain. NS at a registrar would be next in real life."
echo "Private DNS would be: az network private-dns zone + vnet link (-e true = auto-reg)"

if [[ "${APPLY:-0}" != "1" ]]; then
  echo
  echo "Read-only. APPLY=1 ./dns.sh to create then delete."
  exit 0
fi

az group create --name "$RG" --location "$LOC" --output none
az network dns zone create --resource-group "$RG" --name "$ZONE" --output none
az network dns record-set a add-record \
  --resource-group "$RG" --zone-name "$ZONE" --record-set-name www --ipv4-address 20.1.2.3 --output none

az network dns zone show --resource-group "$RG" --name "$ZONE" \
  --query '{name:name,nservers:nameServers}' -o json
az network dns record-set a show --resource-group "$RG" --zone-name "$ZONE" --name www \
  --query '{fqdn:fqdn,ttl:TTL,a:arecords}' -o json

echo "== Cleanup =="
az group delete --name "$RG" --yes --no-wait
echo "Delete started for $RG"
