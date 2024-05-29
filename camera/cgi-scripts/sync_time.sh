#!/bin/bash
#located at /usr/lib/cgi-bin/
# Print HTTP header
echo "Content-Type: text/html"
echo ""

# Read POST data from stdin
read input

# Extract 'time' parameter from input data
new_time=$(echo "$input" | grep -oP 'time=\K[^&]*')

# URL decode the new_time string
new_time_decoded=$(echo -e "$(sed 's/+/ /g;s/%\(..\)/\\x\1/g;' <<<"$new_time")")

# Update system time if new_time is provided
if [ -n "$new_time_decoded" ]; then
    sudo date -s "$new_time_decoded"
    echo "<html><body><h1>Time Updated</h1></body></html>"
else
    echo "<html><body><h1>Error: No time provided</h1></body></html>"
fi
