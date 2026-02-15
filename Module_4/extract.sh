#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 input.txt"
    exit 1
fi

input_file="$1"
output_file="output.txt"

if [[ ! -f "$input_file" ]]; then
    echo "Error: File '$input_file' not found!"
    exit 1
fi

> "$output_file"

while IFS= read -r line
do
    if [[ $line == *"\"frame.time\""* ]]; then
        value=$(echo "$line" | cut -d':' -f2- | tr -d '",' | xargs)
        echo "\"frame.time\": \"$value\"," >> "$output_file"
    fi

    if [[ $line == *"\"wlan.fc.type\""* ]]; then
        value=$(echo "$line" | cut -d':' -f2- | tr -d '",' | xargs)
        echo "\"wlan.fc.type\": \"$value\"," >> "$output_file"
    fi

    if [[ $line == *"\"wlan.fc.subtype\""* ]]; then
        value=$(echo "$line" | cut -d':' -f2- | tr -d '",' | xargs)
        echo "\"wlan.fc.subtype\": \"$value\"," >> "$output_file"
    fi

done < "$input_file"

echo "Done! Extracted values saved in $output_file"
