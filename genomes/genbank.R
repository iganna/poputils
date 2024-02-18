#' Read GenBank file
#' 
#' This function reads a GenBank file and extracts sequence and annotation information.
#' 
#' @param file.gbk Path to the GenBank file.
#' @return A list containing sequences and annotation information.
#' @details This function extracts sequence and annotation information from a GenBank file.
#' It reads the file line by line and extracts the sequence and GFF (General Feature Format) information.
#' 
#' @examples
#' file <- "example.gbk"
#' result <- readGbk(file)
#' 
#' @author Anna Igolkina
readGbk <- function(file.gbk){
  lines <- readLines(file.gbk)
  
  seqs = c()
  gff.all = c()
  
  locus.start <- c(grep("^LOCUS", lines), length(lines) + 1)
  for(i.loc in 1:(length(locus.start) - 1)){
    locus.lines = lines[locus.start[i.loc]:(locus.start[i.loc+1]-1)]
    
    # ---- Create Fasta info ----
    fasta.start <- grep("^ORIGIN", locus.lines)
    fasta.lines = locus.lines[-(1:fasta.start)]
    
    fasta.lines <- sapply(fasta.lines, function(line) gsub("[0-9]|\\s|/", "", line) )
    names(fasta.lines) = NULL
    fasta.seq = paste0(fasta.lines, collapse = '')
    
    locus.len = strsplit(lines[locus.start[i.loc]], '\\s+')[[1]][3]
    locus.name = strsplit(lines[locus.start[i.loc]], '\\s+')[[1]][2]
    
    if(locus.len != nchar(fasta.seq)) stop(paste('Reading',file.gbk,'is failed. Wrong fasta length.'))
    
    seqs[locus.name] = fasta.seq
    
    # ---- Create GFF info ----
    fatures.start <- grep("^FEATURES", locus.lines)
    fatures.lines <- locus.lines[(fatures.start+1):(fasta.start-1)]
    
    # Remove some first spaces
    n.space <- regexpr("\\S", fatures.lines[1])[1] - 1
    fatures.lines <- sub(paste0("^ {", n.space, "}"), "", fatures.lines)
    
    # Find features - those lines with do not start with space
    features.idx <- grep("^ ", fatures.lines, invert = TRUE)
    features.n = length(features.idx)
    features.idx = c(features.idx, length(fatures.lines) + 1)
    
    # Prepare line for work
    fatures.lines <- trimws(fatures.lines, which = "left")
    fatures.lines <- sapply(fatures.lines, function(line) gsub("\\\"", "", line) )
    names(fatures.lines) = NULL
    
    gff = c()
    for(i.f in 1:features.n){
      gff.lines = fatures.lines[features.idx[i.f]:(features.idx[i.f+1]-1)]
      
      # name
      feature.name <- grep("^/locus_tag", gff.lines, value = TRUE)
      if(length(feature.name) == 0) {
        # print(gff.lines)
        next
      }
      s.name = gsub("/locus_tag=", "ID=", feature.name)
      
      idx.info <- paste0(c(s.name,grep("^/locus_tag|^/gene", gff.lines, value = TRUE)), collapse = '')
      
      idx.info =  gsub(" ", "_", idx.info)
      idx.info <- gsub("/", ";", idx.info)
      
      gff.type = strsplit(gff.lines[1], '\\s+')[[1]][1]
      gff.pos = strsplit(gff.lines[1], '\\s+')[[1]][2]
      
      if(length(grep("complement", gff.pos)) == 0){
        gff.pos = strsplit(gff.pos, '\\..')[[1]]
        gff.strand = '+'
      } else {
        gff.pos = sub("complement\\(", "", gff.pos)
        gff.pos = sub(")", "", gff.pos)
        gff.pos = strsplit(gff.pos, '\\..')[[1]]
        gff.strand = '-'
      }
      
      gff.f = c(gff.type, gff.pos, '.', gff.strand, '.', idx.info)
      gff = rbind(gff, gff.f)
      
    }
    # Add parcer Name
    gff = cbind('poputils', gff)
    gff = cbind(locus.name, gff)
    
    gff.all = rbind(gff.all, gff)
    
  }
  
  return(list(seqs = seqs, 
              gff = gff.all))
  
}