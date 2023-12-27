#!/bin/sh

base=$(dirname $0)
echo $base
echo $OSTYPE
cf_ip4_prefer=$(curl -s "https://monitor.gacjie.cn/api/ajax/get_cloud_flare_v4?page=1&limit=10" | jq -r '.data | map(.address) | join(" ")')
cf_ip6_prefer=$(curl -s "https://monitor.gacjie.cn/api/ajax/get_cloud_flare_v6?page=1&limit=10" | jq -r '.data | map(.address) | join(" ")')
cp $base/config_template.yaml $base/../config.yaml
sed -i.bak "s/\$cf_ip4_prefer/$cf_ip4_prefer/" $base/../config.yaml
sed -i.bak "s/\$cf_ip6_prefer/$cf_ip6_prefer/" $base/../config.yaml 
