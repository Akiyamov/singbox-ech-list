#/bin/bash

wget -qO domains_all.lst https://github.com/1andrevich/Re-filter-lists/releases/latest/download/domains_all.lst 
echo '{
    "version": 1,
    "rules": [
        {
            "domain_suffix": [
            ]
        }
    ]
}' > domains_ech.json
echo '{
    "version": 1,
    "rules": [
        {
            "domain_suffix": [
            ]
        }
    ]
}' > domains_noech.json
echo '[]' > amnezia.json
number_of_domains=$(wc -l < domains_all.lst)
number_of_domains_noech=0
number_of_domains_ech=0
start_time=`date +%s`
while read domain; do 
  if dig type65 +noall +answer $domain @1.1.1.1 | grep ech >/dev/null
    then echo $(cat domains_ech.json | jq ".rules[0].domain_suffix |= .  + [\"$domain\"]") > domains_ech.json && echo $domain >> domains_ech.lst && number_of_domains_ech=$((number_of_domains_ech + 1))
    else echo $(cat domains_noech.json | jq ".rules[0].domain_suffix |= .  + [\"$domain\"]") > domains_noech.json && echo "nftset=/$domain/4#inet#fw4#vpn_domains" >> domains_noech_dnsmasq.lst && echo $domain >> domains_noech.lst && echo $(cat amnezia.json | jq ". |= . + [{\"hostname\": \"$domain\", \"ip\": \"\"}]") > amnezia.json && number_of_domains_noech=$((number_of_domains_noech + 1))
  fi
done <domains_all.lst 
finish_time=`date +%s`
