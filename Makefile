.ONESHELL:

default: main

main:
	nextflow run -with-dag pipeline.dot -with-report process_execution.html \
	  -with-timeline timeline.html -resume main.nf

clean:
	sh -c 'rm -rf work/?? work/tmp .nextflow* *.dot results *.html *.txt test sif'

testdownload:
	mkdir -p test sif
	test -f test/md5checksums.txt || \
	lftp -c 'open https://ftp.ncbi.nlm.nih.gov/genomes/refseq/bacteria/Vibrio_cholerae/representative/GCF_000829215.1_ASM82921v1/ ; mirror --continue . test;'
testextract: testdownload
	test -f test/GCF_000829215.1_ASM82921v1_genomic.fna || \
	gzip -d test/*.gz
blastimg:
	test -f  sif/blast.sif || \
	singularity build sif/blast.sif docker://bschiffthaler/ncbi-blast
testmask: testextract
	test -f test/GCF_000829215.1_ASM82921v1_genomic_masked.fna || \
	singularity exec ./sif/blast.sif dustmasker \
	  -in test/GCF_000829215.1_ASM82921v1_genomic.fna \
	  -outfmt fasta | \
	    awk '{ if ($$0 ~ /^>/) { print } else { gsub(/[acgtn]/, "N"); print } }' \
	    > test/GCF_000829215.1_ASM82921v1_genomic_masked.fna

test.config:
	cat <<- EOF > $@
		singularity {
		  enabled = true
		}
		params {
		  gff = "${PWD}/test/GCF_000829215.1_ASM82921v1_genomic.gff"
		  fasta_nomask = "${PWD}/test/GCF_000829215.1_ASM82921v1_genomic.fna"
		  fasta_mask = "${PWD}/test/GCF_000829215.1_ASM82921v1_genomic_masked.fna"
		  fasta_protein = "${PWD}/test/GCF_000829215.1_ASM82921v1_protein.faa"
		  splitN = 100
		  blast_time = "1h"
		  blast_version = "plus"
		  blast_opts = ["-evalue", "0.1"]
		  blast_cpus = 4
		}
		process {
		  executor = "local"
		}
	EOF

testsetup: testdownload testextract blastimg testmask test.config

test: testsetup
	nextflow run -c test.config main.nf
