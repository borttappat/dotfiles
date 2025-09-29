#!/run/current-system/sw/bin/bash

price=$(curl -s "https://api.coingecko.com/api/v3/simple/price?ids=solana&vs_currencies=usd" | jq -r '.solana.usd')

if [ -n "$price" ] && [ "$price" != "null" ]; then
    echo "\$${price}"
else
    echo "ERR"
fi
