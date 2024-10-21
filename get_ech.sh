#/bin/bash

curl -s https://api.github.com/repos/1andrevich/Re-filter-lists/releases/latest | grep "domains_all.lst" | cut -d : -f 2,3 | tr -d \" | wget -qi -
echo '{
    "version": 1,
    "rules": [
        {
            "domain_suffix": [
            ]
        }
    ]
}' > domains.json
number_of_domains=$(wc -l < domains_all.lst)
number_of_domains_noech=0
number_of_domains_ech=0
start_time=`date +%s`
while read domain; do 
  if dig type65 +noall +answer $domain @1.1.1.1 | grep ech >/dev/null
    then echo $domain >> domains_ech.txt && number_of_domains_ech=$((number_of_domains_ech + 1))
    else echo $(cat domains.json | jq ".rules[0].domain_suffix |= .  + [\"$domain\"]") > domains.json && echo $domain >> domains_noech.txt && number_of_domains_noech=$((number_of_domains_noech + 1))
  fi
done <domains_all.lst 
finish_time=`date +%s`
