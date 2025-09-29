#!/run/current-system/sw/bin/bash

price=$(curl -s "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd" | jq -r '.bitcoin.usd')

if [ -n "$price" ] && [ "$price" != "null" ]; then
    formatted_price=$(printf "%d" $price | sed ':a;s/\B[0-9]\{3\}\>/ &/;ta')
    echo "\$${formatted_price}"
else
    echo "ERR"
fi
