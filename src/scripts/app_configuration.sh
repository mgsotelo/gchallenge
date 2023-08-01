#!/bin/bash

# Check if the correct number of arguments is provided
if [ $# -ne 4 ]; then
    echo "Usage: $0 <DB_USER> <DB_PASS> <DB_HOST> <DB_PORT>"
    exit 1
fi

# Input JSON file path
json_file=".secrets.json"

# Arguments
db_user="$1"
db_pass="$2"
db_host="$3"
db_port="$4"

# Update the JSON file using AWK
awk -v user="$db_user" -v pass="$db_pass" -v host="$db_host" -v port="$db_port" '
    /"DB_USER":/ {gsub(/"[^"]*"/, "\""user"\"")}
    /"DB_PASS":/ {gsub(/"[^"]*"/, "\""pass"\"")}
    /"DB_HOST":/ {gsub(/"[^"]*"/, "\""host"\"")}
    /"DB_PORT":/ {gsub(/"[^"]*"/, "\""port"\"")}
    1' "$json_file" > tmp.json && mv tmp.json "$json_file"

echo "JSON file updated successfully."