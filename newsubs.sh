#!/bin/bash

figlet newSubs
echo "made by H4554n M4k1"
# Function to display usage
usage() {
    echo "Usage: $0 -d <domain> -o <old_file>"
    exit 1
}

# Parse command-line arguments
while getopts "d:o:" opt; do
    case $opt in
        d) domain=$OPTARG ;;        # Domain to enumerate
        o) old_file=$OPTARG ;;      # File containing previously enumerated subdomains
        *) usage ;;
    esac
done

# Check if domain and old_file are provided
if [[ -z "$domain" || -z "$old_file" ]]; then
    usage
fi

# Ensure the old file exists
if [[ ! -f "$old_file" ]]; then
    echo "Error: File '$old_file' does not exist."
    exit 1
fi

# Run Subfinder to enumerate new subdomains and save to a temporary file
temp_file=$(mktemp)
subfinder -d "$domain" -all >> "$temp_file"
assetfinder --subs-only "$domain" >> "$temp_file"

# Compare the new subdomains with the old file and extract only the new ones
new_subdomains=$(grep -Fxv -f "$old_file" "$temp_file")

# Display the new subdomains
if [[ -z "$new_subdomains" ]]; then
    echo "No new subdomains found."
else
    echo "New subdomains found:"
    echo "$new_subdomains"
fi

# Optionally append the new subdomains to the old file
if [[ ! -z "$new_subdomains" ]]; then
    read -p "Do you want to update the old file with these new subdomains? (y/n): " update_file
    if [[ "$update_file" == "y" || "$update_file" == "Y" ]]; then
        echo "$new_subdomains" >> "$old_file"
        echo "The old file '$old_file' has been updated with new subdomains."
    fi
fi

# Clean up temporary file
rm "$temp_file"

