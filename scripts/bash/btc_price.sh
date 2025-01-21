#!/run/current-system/sw/bin/bash

# Fetch Bitcoin price using curl and jq
price=$(curl -s "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd" | jq -r '.bitcoin.usd')

# Check if price was fetched successfully
if [ -n "$price" ] && [ "$price" != "null" ]; then
    # Format price with commas and 2 decimal places
    formatted_price=$(printf "%'.2f" $price)
    echo "\$${formatted_price}"
else
    echo "ERR"
fi
