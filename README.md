# singbox-ech-list

Идея взята у [Ori с ntc.party](https://ntc.party/t/%D0%B8%D1%81%D0%BF%D0%BE%D0%BB%D1%8C%D0%B7%D0%BE%D0%B2%D0%B0%D0%BD%D0%B8%D0%B5-esni-encrypted-sni-%D0%B2-%D1%80%D0%BE%D1%81%D1%81%D0%B8%D0%B8/68/58).  
Скрипт перебирает домены из [Re:filter](https://github.com/1andrevich/Re-filter-lists) и с помощью `dig` отбирает домены без ech. После этого sing-box создает rule-set, который можно использовать для обхода.