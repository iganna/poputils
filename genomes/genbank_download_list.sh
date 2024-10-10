#!/bin/bash


# ----------------------------------------------------------------------------
#            ERROR HANDLING BLOCK
# ----------------------------------------------------------------------------

# Exit immediately if any command returns a non-zero status
set -e

# Keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG

# Define a trap for the EXIT signal
trap 'catch $?' EXIT

# Function to handle the exit signal
catch() {
    # Check if the exit code is non-zero
    if [ $1 -ne 0 ]; then
        echo "\"${last_command}\" command failed with exit code $1."
    fi
}

# ----------------------------------------------------------------------------
#             FUNCTIONS
# ----------------------------------------------------------------------------

# Function to show usage information
usage() {
    echo "Usage: $0 -g genome_id [-p path] [-h]"
    echo "  -f  file with genome IDs"
    echo "  -p  Path where the file should be saved (default: ../data)"
    echo "  -h  Display this help and exit"
}

# ----------------------------------------------------------------------------
#            PARAMETERS
# ----------------------------------------------------------------------------

# Initialize an empty variable for the genome_id
name=""
genome_id=""
path="../data/"  # Default path

# Process command line arguments
while [ $# -gt 0 ]; do
    case $1 in
        -f)
            file="$2"
            shift # Move past the argument value
            ;;
        -p)
            path="$2"
            shift # Move past the path value
            ;;
        -h)
            usage
            exit 1
            ;;
        *)
            usage
            ;;
    esac
    shift # Move to the next argument
done


# Check if genome_id was provided
if [ -z "${file}" ]; then
    echo "Error: -f <file> argument is required"
    usage
    exit 1
fi

# Check and append a slash to $path if missing
if [[ "$path" != */ ]]; then
    path="$path/"
fi


# ----------------------------------------------------------------------------
#           MAIN 
# ----------------------------------------------------------------------------

echo $file
while IFS= read -r line; do
    echo $line
    if [[ -n "$line" ]]; then
        ./genbank_download.sh -g "$line" -p "$path"
    fi
done < "$file"

printf "\e[38;5;158m  %s\e[0m\n" "Done."

