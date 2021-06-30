# nf-pseudopipe

Nextflow pseudopipe runner

## Getting started

### Data needed

1. A hard masked genome file
2. A non-masked genome file
3. A GFF3 file with exon locations
4. A protein fasta file

### Preparing the data

There are a number of caveats when preparing data. Firstly, unplaced scaffolds
in an assembly could lead to false positives in case the gene location was not
called in the annotation pipeline. If you want to be conservative with the
pseudogene predictions, subset the genome and protein files to contain
chromosomes only.

Further caveats:

* Supply all files uncompressed (ppipe doesn't like gzipped data)
* The GFF file must contain features "exon" or "CDS"
* The protein fasta file should contain only _primary_ proteins, not isoforms

### Preparing the configuration

In the most simple case, just modify the `nextflow.config` file with file paths
pointing to your DNA, Protein and GFF files. By default `singularity` is enabled although you are free to substitute this with docker. It is _not recommended_ to run outside of the containers on your system as things are very likely to break.

See [nextflow configuration](https://www.nextflow.io/docs/latest/config.html) for an in-depth reference on how to tune nextflow to your computational environment

### Starting the pipeline

```bash
Nextflow run main.nf
```

### Results

The main results file will be located in `results/out/pgenes/out_pgenes.txt`.
