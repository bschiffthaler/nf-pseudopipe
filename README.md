# nf-pseudopipe

Nextflow pseudopipe runner

## Getting started

1. A hard masked genome file
2. A non-masked genome file
3. A GFF3 file with exon locations
4. A protein fasta file
5. A file with allowed chromosome locations

## Caveats

* Supply all files uncompressed (ppipe doesn't like gzipped data)
* The allowed locations file contains the chromosome FASTA header (without the leading `>` and up to the first whitespace character)
  - Example: `>scaffold1124 putative choloroplast` --> `scaffold1124`
