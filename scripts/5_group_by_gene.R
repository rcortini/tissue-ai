#!/usr/local/bin/Rscript

# check for proper invocation
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1) {
  stop("Usage: 5_group_by_gene.R <tissue_ai_home>", call. = FALSE)
}

# get arguments from command line
tissue.ai.home <- args[1]

# load dplyr which will allow us to speed up significantly
suppressMessages(library(dplyr))

# load the biomaRt library, along with the mart that we will use to get our data
library(biomaRt)
mart <- useMart(biomart = "ensembl", dataset = "hsapiens_gene_ensembl")

# get the mapping between the transcript ids (with version) and gene ids
transcript.to.gene <- getBM(attributes = c("ensembl_transcript_id_version",
					   "ensembl_gene_id_version"),
			    mart = mart)
rownames(transcript.to.gene) <- transcript.to.gene$ensembl_transcript_id_version

# iterate through all the experiments
experiments.dir <- sprintf("%s/data/experiments", tissue.ai.home)
experiment.dirs <- list.dirs(experiments.dir, recursive = FALSE)
for (experiment.dir in experiment.dirs) {

  # print info for the user
  cat("Analzying ", experiment.dir, "\n")
  flush.console()

  # iterate through the file name(s) associated to the requested experiment
  count <- 1
  replicate.fname <- sprintf("%s/replicate-%d.info", experiment.dir, count)
  while (file.exists(replicate.fname)) {

    # get the quant file (here we don't check whether the quant files exists,
    # because we already ran the jobs_verify step, so supposing here that
    # everyhing is correct
    quant.fname <- sprintf("%s/replicate-%d-quant/quant.sf", experiment.dir, count)

    # parse the gene quantification file
    quant <- read.csv(quant.fname, sep='\t')
    rownames(quant) <- quant$Name
    
    # write the gene ID of each transcript
    quant$GeneID <- transcript.to.gene[rownames(quant), "ensembl_gene_id_version"]
    
    # beautiful one-liner that is lightning-fast
    # and calculates sum by gene of transcript counts
    bygene <- quant %>%
	      dplyr::group_by(GeneID) %>%
	      dplyr::summarize(GeneCounts = sum(NumReads),
			       GeneTPM = sum(TPM),
			       TotalLength = sum(Length),
			       TotalEffectiveLength = sum(EffectiveLength))
   
    # write output
    output.fname <- sprintf("%s/replicate-%d-quant/quant-by-gene.tsv",
			    experiment.dir, count)
    write.table(bygene, file = output.fname, sep = "\t",
		quote = FALSE, row.names = FALSE)
    
    # proceed to next replicate file
    count <- count+1
    replicate.fname <- sprintf("%s/replicate-%d.info", experiment.dir, count)
  }
}
