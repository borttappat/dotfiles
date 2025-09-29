#!/run/current-system/sw/bin/bash

# Fetch Bitcoin price using curl and jq
price=$(curl -s "https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=usd" | jq -r '.ethereum.usd')

# Check if price was fetched successfully
if [ -n "$price" ] && [ "$price" != "null" ]; then
    echo "\$${price}"
else
    echo "ERR"
fi
