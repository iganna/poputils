#' Count the Number of Pairwise Gametes for Adjacent SNPs
#'
#' This function calculates the number of different gametes (genetic combinations)
#' that can be formed by pairs of neighbouring biallelic markers (e.g., SNPs).
#' It is designed to work with a matrix where rows represent different markers and
#' columns represent different individuals.
#'
#' @param x A numeric matrix where each row represents a marker and each column 
#' represents an individual. The matrix should contain binary data (0 and 1), 
#' where 0 and 1 represent the two possible alleles for each marker.
#'
#' @return An integer vector, where each element represents the number of different
#' gametes that can be formed by a pair of neighbouring markers The length of the vector
#' is equal `nrow(x - 1)`, as it calculates the combinations for each pair of neighbouring rows.
#' The interpretation of the results is as follows:
#' - If the result is 1, both markers are not variable.
#' - If the result is 2, the markers are identical.
#' - If the result is 3, the markers could follow a simple bifurcating phylogeny.
#' - If the result is 4, the recombination or a repeat mutation occurred between the markers.
#'
#' @examples
#' # Example matrix of SNPs
#' snp_matrix <- matrix(c(0, 0, 1, 1,
#'                        0, 1, 1, 0, 
#'                        1, 0, 1, 1, 
#'                        0, 1, 0, 0), 
#'                      nrow = 4, byrow = TRUE)
#' # Calculate pairwise gametes, result should be `4 3 2`
#' neiGametes(snp_matrix)
#' 
#' @author Anna Igolkina
#'
#' @export
neiGametes <- function(x){
  
  d.x.nei = x[-1,] + 2 * x[-nrow(x),]
  
  n0 = rowSums(d.x.nei == 0)
  n1 = rowSums(d.x.nei == 1)
  n2 = rowSums(d.x.nei == 2)
  n3 = rowSums(d.x.nei == 3)
  
  n.gam = (n0 != 0) + (n1 != 0) + (n2 != 0) + (n3 != 0)
  
  return(n.gam)
}