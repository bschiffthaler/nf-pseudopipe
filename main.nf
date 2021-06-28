nextflow.enable.dsl = 2

process prep_gff {
  container "bschiffthaler/python:3.9"
  cpus 1

  input:
  path script
  path gff
  path allowlist

  output:
  path "exlocs"

  script:

  """
  python ${script} ${gff} ${allowlist}
  """
}

process index_fasta {
  container "bschiffthaler/pseudopipe:1a279cc6"
  cpus 1

  input:
  path fasta_mask

  output:
  path "*.{nhr,nin,nsd,nsi,nsq}", emit: index

  script:

  """
  formatdb -i ${fasta_mask} -o T -p F
  """
}

process prep_fasta {
  container "bschiffthaler/python:3.9"
  cpus 1

  input:
  path script
  path fasta
  path allowlist

  output:
  path "split_out"

  script:

  """
  python ${script} ${fasta} ${allowlist}
  """
}

process prep_ppipe_out {
  container "bschiffthaler/pseudopipe:1a279cc6"
  cpus 1

  input:
  path script
  path split

  output:
  path "out"

  script:

  """
  mkdir out
  bash ${script}
  """
}

process blast {
  container "bschiffthaler/pseudopipe:1a279cc6"
  cpus 1
  time "${params.blast_time}"

  input:
  path fasta_mask
  tuple path(nhr), path(nin), path(nsd), path(nsi), path(nsq)
  path split

  output:
  path "split*"

  script:

  """
  sp=\$(basename ${split})
  blastall -p tblastn -m 8 -z 3.1e9 -e .1 \
    -d ${fasta_mask} -i ${split} -o \${sp}.Out \
    >\${sp}.Status 2>&1
  n=\$(echo \$sp | cut -d . -f 2)
  o=\$(printf "%04d" \$n)
  mv \${sp}.Out split\${o}.Out
  mv \${sp}.Status split\${o}.Status
  cat ${split} > split\${o}
  """
}

process pseudopipe {
  container "bschiffthaler/pseudopipe:1a279cc6"
  cpus 1
  publishDir "results"

  input:
  path fasta_mask
  tuple path(nhr), path(nin), path(nsd), path(nsi), path(nsq)
  path fasta_protein
  path fasta_chr
  path exlocs
  path out

  output:
  path "out"

  script:

  """
  RP=\$(realpath .)
  /usr/local/bin/pseudopipe/bin/pseudopipe.sh \
    \${RP}/out \
    \${RP}/${fasta_mask} \
    \${RP}/${fasta_chr}/%s.fa \
    \${RP}/${fasta_protein} \
    \${RP}/${exlocs}/%s_exLocs \
    0
  """
}

workflow {
  splits = Channel.fromPath(params.fasta_protein)
  .splitFasta(by: params.splitN, file: "split")

  prep_gff("${baseDir}/src/prep_gff3.py", params.gff, params.allowlist)
  prep_fasta("${baseDir}/src/prep_fasta.py", params.fasta_nomask, params.allowlist)
  index_fasta(params.fasta_mask)
  blast(params.fasta_mask, index_fasta.out.index, splits)

  blasts = blast.out.collect()

  prep_ppipe_out("${baseDir}/src/prep_ppipe_out.sh", blasts)

  pseudopipe(params.fasta_mask, index_fasta.out.index, params.fasta_protein,
    prep_fasta.out, prep_gff.out, prep_ppipe_out.out)

}