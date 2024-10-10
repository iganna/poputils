# poputils

`poputils` is a collection of convenient tools and functions for data analysis and processing in bioinformatics. 

## Features

### Download genomes from the NCBI Genome collection

- One genome
```bash
cd genomes 
./genbank_download.sh -g <genome_id> -p <output_folder> [-x <my_name>]
```

Example for the *Homo sapiens* genome:
```bash
./genbank_download.sh -g GCA_000001405.29 -p data -x human
````

- List of genomes
```bash
cd genomes 
./genbank_download_list.sh -f <file_with_genome_ids> -p <output_folder> 

```

Example for the *Arabidopsis* genomes (*thaliana* and *lyrata*):
```bash
echo -e "GCA_000001735.2\nGCA_000004255.1" > species.txt
./genbank_download_list.sh -f species.txt -p species
````

### SNP statisticks
