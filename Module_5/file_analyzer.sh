#!/bin/bash

ERROR_LOG="errors.log"

# ---------------- Error Handler ----------------
error() {
    echo "[ERROR] $1" | tee -a "$ERROR_LOG" >&2
}

# ---------------- Help Menu (Here Document) ----------------
show_help() {
cat <<EOF
Usage: $0 [options]

Options:
  -d <directory>   Directory to search recursively
  -k <keyword>     Keyword to search
  -f <file>        Search keyword in a specific file
  --help           Display this help menu

Examples:
  $0 -d logs -k error
  $0 -f script.sh -k TODO
EOF
}

# ---------------- Recursive Function ----------------
search_directory() {
    local dir="$1"
    local keyword="$2"

    for item in "$dir"/*; do
        if [ -f "$item" ]; then
            grep -Hn "$keyword" "$item" 2>/dev/null
        elif [ -d "$item" ]; then
            search_directory "$item" "$keyword"
        fi
    done
}

# ---------------- Argument Validation ----------------
validate_inputs() {
    if [[ -z "$keyword" ]]; then
        error "Keyword cannot be empty"
        exit 1
    fi
}

# ---------------- getopts Parsing ----------------
while getopts ":d:k:f:-:" opt; do
    case "$opt" in
        d) directory="$OPTARG" ;;
        k) keyword="$OPTARG" ;;
        f) file="$OPTARG" ;;
        -)
            case "$OPTARG" in
                help) show_help; exit 0 ;;
                *) error "Unknown option --$OPTARG" ;;
            esac ;;
        \?) error "Invalid option: -$OPTARG" ;;
    esac
done

validate_inputs

# ---------------- File Search (Here String) ----------------
if [[ -n "$file" ]]; then
    if [[ ! -f "$file" ]]; then
        error "File does not exist"
        exit 1
    fi
    grep -n "$keyword" <<< "$(cat "$file")"
fi

# ---------------- Directory Search ----------------
if [[ -n "$directory" ]]; then
    if [[ ! -d "$directory" ]]; then
        error "Directory does not exist"
        exit 1
    fi
    search_directory "$directory" "$keyword"
fi

echo "Script executed successfully. Exit status: $?"
