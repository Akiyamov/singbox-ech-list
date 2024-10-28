# singbox-ech-list

Список сайтов которые используют/не используют Encrypted Client Hello(ECH)  

## Зачем

После того как Cloudflare включил ECH часть сайтов стала доступна без проксирования. Это получается из-за того, что ТСПУ видит домен cloudflare вместо настоящего домена сайта и, таким образом, ТСПУ не может отработать и пустить трафик. Для работы нужно использовать любой DoH/DoT DNS, желательно не из России, так как они могут попросту вырезать айпи.  

Идея взята у [Ori с ntc.party](https://ntc.party/t/%D0%B8%D1%81%D0%BF%D0%BE%D0%BB%D1%8C%D0%B7%D0%BE%D0%B2%D0%B0%D0%BD%D0%B8%D0%B5-esni-encrypted-sni-%D0%B2-%D1%80%D0%BE%D1%81%D1%81%D0%B8%D0%B8/68/58).  
Скрипт перебирает домены из [Re:filter](https://github.com/1andrevich/Re-filter-lists) и с помощью `dig` отбирает домены без ech. После этого sing-box создает rule-set, который можно использовать для обхода.

## Как поставить 

### Прямые ссылки на файлы

* Sing-box ECH Rule-set https://github.com/Akiyamov/singbox-ech-list/releases/latest/download/domains_ech.srs
* Sing-box NoECH Rule-set https://github.com/Akiyamov/singbox-ech-list/releases/latest/download/domains_noech.srs
* AmneziaVPN NoECH JSON https://github.com/Akiyamov/singbox-ech-list/releases/latest/download/amnezia.json
* DNSMasq+NFTables https://github.com/Akiyamov/singbox-ech-list/releases/latest/download/domains_noech_dnsmasq.lst

### Xray 

TBD

### Sing-box

<details>
    <summary>Нажмите сюда, чтоб раскрыть</summary>

Скрипт генерирует готовый [rule-set](https://sing-box.sagernet.org/configuration/rule-set/), поэтому достаточно его импортировать в ваш конфиг  
rule-set для доменов без ech
```json
{
    "route": {
        "rule_set": [
            {
                "download_detour": "bypass",
                "format": "binary",
                "tag": "no_ech",
                "type": "remote",
                "url": "https://github.com/Akiyamov/singbox-ech-list/releases/latest/download/domains_noech.srs"
            }
        ],
    }
}
```
rule-set для доменов с ech
```json
{
    "route": {
        "rule_set": [
            {
                "download_detour": "bypass",
                "format": "binary",
                "tag": "ech",
                "type": "remote",
                "url": "https://github.com/Akiyamov/singbox-ech-list/releases/latest/download/domains_ech.srs"
            }
        ],
    }
}
```
</details>

### Amnezia

<details>
    <summary>Нажмите сюда, чтоб раскрыть</summary>

Скрипт генерирует список для AmneziaVPN, который скачать можно [здесь](https://github.com/Akiyamov/singbox-ech-list/releases/latest/download/amnezia.json). Для этого в разделе "Раздельное туннелирование" нужно выбрать в выпадающем списке "Только адреса из списка должны открываться через VPN" и импортировать список. Самому приложению станет плохо. Очень плохо. После перезапуска приложение будет нормально работать. Все это настроено было у друга и лично не проверял. 
</details>

### itdog/dnsmasq+nftables

<details>
    <summary>Нажмите сюда, чтоб раскрыть</summary>

В данном способе сайты маршрутизируются по схеме от [itdog](https://habr.com/ru/articles/767464/), для настройки потребуется поменять родной скрипт getdomains. Он расположен в `/etc/init.d/getdomains`.
```sh
#!/bin/sh /etc/rc.common

START=99

start () {
#    DOMAINS=https://raw.githubusercontent.com/itdoginfo/allow-domains/main/Russia/inside-dnsmasq-nfset.lst
    count=0
    while true; do
        if curl -m 3 github.com; then
            wget -qO /tmp/dnsmasq.d/domains.lst https://github.com/Akiyamov/singbox-ech-list/releases/latest/download/domains_noech_dnsmasq.lst
            #curl -f $DOMAINS --output /tmp/dnsmasq.d/domains.lst
            break
        else
            echo "GitHub is not available. Check the internet availability [$count]"
            count=$((count+1))
        fi
    done

    if dnsmasq --conf-file=/tmp/dnsmasq.d/domains.lst --test 2>&1 | grep -q "syntax check OK"; then
        /etc/init.d/dnsmasq restart
    fi
}
```
</details>