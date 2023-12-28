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
cf_ip4=$(curl -s "https://www.cloudflare.com/ips-v4")
cf_ip6=$(curl -s "https://www.cloudflare.com/ips-v6")

if [[ "$cf_ip4" == *"html"* ]];then
	echo '173.245.48.0/20
103.21.244.0/22
103.22.200.0/22
103.31.4.0/22
141.101.64.0/18
108.162.192.0/18
190.93.240.0/20
188.114.96.0/20
197.234.240.0/22
198.41.128.0/17
162.158.0.0/15
104.16.0.0/13
104.24.0.0/14
172.64.0.0/13
131.0.72.0/22' > "$ruleset_dir/cf_ip4.txt"
else
	echo "$cf_ip4" > "$ruleset_dir/cf_ip4.txt"
fi

if [[ "$cf_ip6" == *"html"* ]];then
	echo '2400:cb00::/32
2606:4700::/32
2803:f800::/32
2405:b500::/32
2405:8100::/32
2a06:98c0::/29
2c0f:f248::/32' > "$ruleset_dir/cf_ip6.txt"
else
	echo "$cf_ip6" > "$ruleset_dir/cf_ip6.txt"
fi


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
