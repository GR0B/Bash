#!/bin/bash
# Robert Sturzbecher 2025-02-14
# Hashcheck
# Generate a index of all files with a MD5 hash or compare the hash of files with the index file.


# ANSI color codes
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to generate MD5 hash
generate_md5() {
    md5sum "$1" | awk '{print $1}'
}

# Function to create index file
create_index() {
    local directory=$1
    find "$directory" -type f -print0 | while IFS= read -r -d '' file; do
        local md5=$(generate_md5 "$file")
        local size=$(stat -c%s "$file")
        local modified_date=$(stat -c%y "$file")
        echo "Indexing: $file"
        echo "$file,$size,$modified_date,$md5" >> index.csv
    done
}

# Function to compare files with index
compare_files() {
    local index_file=$1
    local directory=$2
    while IFS=, read -r file size modified_date md5; do
        if [[ -f "$file" ]]; then
            local current_md5=$(generate_md5 "$file")
            if [[ "$current_md5" != "$md5" ]]; then
                echo -e "${RED} File changed:${NC} $file"
            else
                echo -e "${GREEN} File unchanged:${NC} $file"
            fi
        else
            echo -e "${YELLOW} File missing:${NC} $file"
        fi
    done < "$index_file"
}

# Main script logic
if [[ "$1" == "create" ]]; then
    echo "Creating index for directory: $2"
    create_index "$2"
    echo "Index creation completed."
elif [[ "$1" == "compare" ]]; then
    echo "Comparing files with index file: $2"
    compare_files "$2" "$3"
    echo "Comparison completed."
else
    echo "Hashcheck - create|compare MD5 hash of files with an index csv file"
    echo "Usage: $0 {create|compare} <directory> [index_file]"
fi
