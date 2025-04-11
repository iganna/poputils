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
    echo "  -g  Genome ID to download"
    echo "  -p  Path where the file should be saved (default: ../data)"
    echo "  -x  Name of the file"
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
        -g)
            genome_id="$2"
            shift # Move past the argument value
            ;;
        -p)
            path="$2"
            shift # Move past the path value
            ;;
        -x)
            name="$2"
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
if [ -z "${genome_id}" ]; then
    echo "Error: -g genome_id argument is required"
    usage
    exit 1
fi

# Check and append a slash to $path if missing
if [[ "$path" != */ ]]; then
    path="$path/"
fi

[ ! -d "$path" ] && mkdir -p "$path"

if [ "$name" = "" ]; then
    name=${genome_id}
fi

# ----------------------------------------------------------------------------
#           MAIN 
# ----------------------------------------------------------------------------

# Check if the final file already exists
if [ -f "${path}/${name}.fasta" ]; then
    echo "Final file ${name}.fasta already exists. Exiting script."
    exit 0
fi

# Download the genome data
curl -L "https://api.ncbi.nlm.nih.gov/datasets/v2alpha/genome/accession/${genome_id}/download?include_annotation_type=GENOME_FASTA" -o "${path}/${genome_id}.zip"

echo "Download complete. File saved to ${path}/${genome_id}.zip"

# Get the genome file
unzip -q "${path}/${genome_id}.zip" -d "${path}"
fna_file=$(find "${path}/ncbi_dataset/data/${genome_id}/" -type f -name "*fna" -print -quit)


# Копируем файл .fna из распакованной директории в целевую директорию
cp "${fna_file}" "${path}/"

# Delete intermediate files
rm -rf ${path}/ncbi_dataset/
rm "${path}/${genome_id}.zip"
rm ${path}README.md

mv "${path}md5sum.txt" "${path}${genome_id}_md5sum.txt"


# Rename and save the name

if [ "$name" != "" ]; then
    fna_filename=$(basename "${fna_file}")
    mv ${path}${fna_filename}   ${path}${name}.fasta
    echo -e "${fna_filename}\t${name}.fasta" >> "${path}names.txt"
fi





