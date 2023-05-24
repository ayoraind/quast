// assess assembly with Quast
process QUAST {
  tag { sample_id }

 // publishDir "${params.output_dir}", mode: 'copy'

  input:
  tuple val(sample_id), path(assembly)

  output:
  path("${sample_id}"), emit: quast_dir_ch
  tuple(val(sample_id), path("${sample_id}/transposed_report.tsv"), emit: quast_report_ch)
  path("${sample_id}/${sample_id}.tsv"), emit: quast_transposed_report_ch
  path "versions.yml" , emit: versions_ch

  """
  quast.py ${assembly} --threads $task.cpus -o $sample_id
  # mkdir ${sample_id}
  #ln -s \$PWD/report.tsv ${sample_id}/report.tsv
  cp ${sample_id}/transposed_report.tsv ${sample_id}/${sample_id}.tsv

  cat <<-END_VERSIONS > versions.yml
   "${task.process}":
        quast: \$(quast.py --version 2>&1 | sed 's/^.*QUAST v//; s/ .*\$//')
  END_VERSIONS
  """
}

// summarize
process QUAST_SUMMARY {
    publishDir "${params.output_dir}", mode:'copy'
    tag { 'combine quast transposed files'}


    input:
    path(quast_files)
    val(sequencing_date)

    output:
    path("combined_quast_${sequencing_date}.tsv"), emit: quast_comb_ch


    script:
    """
    QUAST_FILES=(${quast_files})

    for index in \${!QUAST_FILES[@]}; do
    QUAST_FILE=\${QUAST_FILES[\$index]}

    # add header line if first file
    if [[ \$index -eq 0 ]]; then
      echo "\$(head -1 \${QUAST_FILE})" >> combined_quast_${sequencing_date}.tsv
    fi
    echo "\$(awk 'FNR==2 {print}' \${QUAST_FILE})" >> combined_quast_${sequencing_date}.tsv
    done

    """
}

// QUAST MultiQC
process QUAST_MULTIQC {
  tag { 'multiqc for quast' }
  memory { 4.GB * task.attempt }

  publishDir "${params.output_dir}/quality_reports",
    mode: 'copy',
    pattern: "multiqc_report.html",
    saveAs: { "quast_multiqc_report.html" }

  input:
  path(quast_files) 

  output:
  path("multiqc_report.html")

  script:
  """
  multiqc --interactive .
  """
}
