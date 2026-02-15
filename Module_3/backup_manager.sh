#!/bin/bash

# -------------------------------
# Command-line arguments
# -------------------------------
SOURCE_DIR="$1"
BACKUP_DIR="$2"
EXTENSION="$3"

# Check arguments
if [ $# -ne 3 ]; then
    echo "Usage: $0 <source_dir> <backup_dir> <extension>"
    exit 1
fi

# -------------------------------
# Create backup directory if not exists
# -------------------------------
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create backup directory"
        exit 1
    fi
fi

# -------------------------------
# Globbing & Array
# -------------------------------
files=("$SOURCE_DIR"/*"$EXTENSION")

# Check if no files found
if [ ! -e "${files[0]}" ]; then
    echo "No files with extension $EXTENSION found."
    exit 0
fi

# -------------------------------
# Export variable
# -------------------------------
export BACKUP_COUNT=0
TOTAL_SIZE=0

echo "Files to be backed up:"
echo "-----------------------"

# -------------------------------
# Backup Process
# -------------------------------
for file in "${files[@]}"; do
    size=$(stat -c%s "$file")
    echo "$(basename "$file") - $size bytes"

    dest="$BACKUP_DIR/$(basename "$file")"

    if [ -f "$dest" ]; then
        if [ "$dest" -ot "$file" ]; then
            cp "$file" "$dest"
            ((BACKUP_COUNT++))
            ((TOTAL_SIZE+=size))
        fi
    else
        cp "$file" "$dest"
        ((BACKUP_COUNT++))
        ((TOTAL_SIZE+=size))
    fi
done

# -------------------------------
# Report Generation
# -------------------------------
REPORT="$BACKUP_DIR/backup_report.log"

{
echo "Backup Summary Report"
echo "---------------------"
echo "Total files backed up: $BACKUP_COUNT"
echo "Total size backed up: $TOTAL_SIZE bytes"
echo "Backup directory: $BACKUP_DIR"
echo "Date: $(date)"
} > "$REPORT"

echo "Backup completed. Report saved to $REPORT"
