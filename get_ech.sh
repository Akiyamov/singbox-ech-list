#/bin/bash

# Checking dependencies
if ! command -v jq &> /dev/null; then
  echo "Package \"jq\" is not installed. Please install \"jq\" to continue."
  exit 1
fi

if ! command -v dig &> /dev/null; then
  echo "Package \"dig\" is not installed. Please install \"dnsutils\" to continue."
  exit 1
fi

if ! command -v parallel &> /dev/null; then
  read -p "Package \"parallel\" is not installed. Script will need 4 hours to complete in sequential mode. Are you sure? (y/N)" seq_choice
  case "$seq_choice" in 
    y|Y ) echo "Running script in sequential mode.";;
    n|N ) echo "Aborting script." && exit 1;;
    * ) echo "Invalid response." && exit 1;;
  esac
fi

# Getting a file with blocked domains
wget -qO domains_all.lst https://github.com/1andrevich/Re-filter-lists/releases/latest/download/domains_all.lst

# Initializing files
> domains_ech.lst
> domains_noech.lst
> domains_noech_dnsmasq.lst
> domains_ech.json
> domains_noech.json
> amnezia.json

parallel_requests=10
number_of_domains=$(wc -l < domains_all.lst)
start_time=`date +%s`

echo "Number of domains: $number_of_domains"

# Function checking the domain and writing to the corresponding .lst file
process_domain() {
  local domain="$1"

  if dig type65 +noall +answer "$domain" @1.1.1.1 | grep -q ech; then
    echo "$domain" >> domains_ech.lst
  else
    echo "$domain" >> domains_noech.lst
    echo "nftset=/$domain/4#inet#fw4#vpn_domains" >> domains_noech_dnsmasq.lst
  fi
}

export -f process_domain

# Selecting a processing method depending on the presence of a dependency
if command -v parallel &> /dev/null; then
  cat domains_all.lst | parallel -j $parallel_requests process_domain
else
  while IFS= read -r domain; do
    process_domain "$domain"
  done < domains_all.lst
fi

# Saving .json files
printf "\rGenerating domains_ech.json file from created list"
jq -R -s -c '{version: 1, rules: [{ domain_suffix: split("\n") | .[:-1]}]}' domains_ech.lst > domains_ech.json
printf "\rGenerating domains_noech.json file from created list"
jq -R -s -c '{version: 1, rules: [{ domain_suffix: split("\n") | .[:-1]}]}' domains_noech.lst > domains_noech.json
printf "\rGenerating amnezia.json file from created list"
jq -R -s -c 'split("\n") | .[:-1] | map({hostname: ., ip: ""})' domains_noech.lst > amnezia.json

printf "\rGeneration of .json files has been successfully completed!"

finish_time=`date +%s`
echo -e "\nCompleted for $((finish_time - start_time)) seconds."
