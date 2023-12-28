#!/bin/sh

china_ip_list_url="https://raw.githubusercontent.com/pmkol/easymosdns/rules/china_ip_list.txt"
gfw_ip_list_url="https://raw.githubusercontent.com/pmkol/easymosdns/rules/gfw_ip_list.txt"
china_domain_list_url="https://raw.githubusercontent.com/pmkol/easymosdns/rules/china_domain_list.txt"
gfw_domain_list_url="https://raw.githubusercontent.com/pmkol/easymosdns/rules/gfw_domain_list.txt"
cdn_domain_list_url="https://raw.githubusercontent.com/pmkol/easymosdns/rules/cdn_domain_list.txt"

base=$(dirname $0)
ruleset_dir="$base/../rules"
append_ruleset="$base/./appends"



echo "Downloading Original RuleSet"
mkdir -p $ruleset_dir
curl -s -o "$ruleset_dir/china_ip_list.txt" -L "$china_ip_list_url"
curl -s -o "$ruleset_dir/gfw_ip_list.txt" -L "$gfw_ip_list_url"
curl -s -o "$ruleset_dir/china_domain_list.txt" -L "$china_domain_list_url"
curl -s -o "$ruleset_dir/gfw_domain_list.txt" -L "$gfw_domain_list_url"
curl -s -o "$ruleset_dir/cdn_domain_list.txt" -L "$cdn_domain_list_url"

echo "Append custom rules"
FILES="$append_ruleset/*.txt"
for f in $FILES;do
	base_name="$(basename -- $f)"
	cat "$f" >> "$ruleset_dir/$base_name"
done


echo "Downloading Cloudflare IP set"
curl -s -o "$ruleset_dir/cf_ip4.txt" "https://www.cloudflare.com/ips-v4"
curl -s -o "$ruleset_dir/cf_ip6.txt" "https://www.cloudflare.com/ips-v6"

echo "Set best cloudflare ip"
cf_ip4_prefer=$(curl -s "https://monitor.gacjie.cn/api/ajax/get_cloud_flare_v4?page=1&limit=10" | jq -r '.data | map(.address) | join(" ")')
cf_ip6_prefer=$(curl -s "https://monitor.gacjie.cn/api/ajax/get_cloud_flare_v6?page=1&limit=10" | jq -r '.data | map(.address) | join(" ")')
cp $base/configs/* $base/../
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	sed -i "s/\$cf_ip4_prefer/$cf_ip4_prefer/" $base/../sequence.yaml
	sed -i "s/\$cf_ip6_prefer/$cf_ip6_prefer/" $base/../sequence.yaml
elif [[ "$OSTYPE" == "darwin"* ]]; then
	sed -i.bak "s/\$cf_ip4_prefer/$cf_ip4_prefer/" $base/../sequence.yaml
	sed -i.bak "s/\$cf_ip6_prefer/$cf_ip6_prefer/" $base/../sequence.yaml
	rm sequence.yaml.bak
fi
