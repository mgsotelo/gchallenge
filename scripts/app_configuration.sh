#!/bin/bash

# Check if the correct number of arguments is provided
if [ $# -ne 4 ]; then
    echo "Usage: $0 <DB_USER> <DB_PASS> <DB_HOST> <DB_PORT>"
    exit 1
fi

# Input JSON file path
json_file=".secrets.json"

# Arguments
DB_USER=$1
DB_PASS=$2
DB_HOST=$3
DB_PORT=$4

# Use sed with regular expressions to modify the JSON file
sed -i "s/\"DB_USER\": \"[^\"]*\"/\"DB_USER\": \"$DB_USER\"/g" $json_file
sed -i "s/\"DB_PASS\": \"[^\"]*\"/\"DB_PASS\": \"$DB_PASS\"/g" $json_file
sed -i "s/\"DB_HOST\": \"[^\"]*\"/\"DB_HOST\": \"$DB_HOST\"/g" $json_file
sed -i "s/\"DB_PORT\": \"[^\"]*\"/\"DB_PORT\": \"$DB_PORT\"/g" $json_file

echo "JSON file modified successfully."