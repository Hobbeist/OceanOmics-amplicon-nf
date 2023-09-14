process VSEARCH_UCHIME3DENOVO {
    tag "$prefix"
    label 'process_medium'
    container 'quay.io/biocontainers/vsearch:2.21.1--h95f258a_0'

    input:
    val prefix
    path reads

    output:
    tuple val(prefix), path("*.fa"), emit: zotu_fasta
    path "versions.yml"            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    vsearch --uchime3_denovo ${reads} ${args} tmp.fa --relabel zotu

    # This makes sure each read is only two lines
    awk '/^>/ {if (seq) print seq; printf("%s\\n",\$0); seq=""; next} {seq = seq \$0} END {if (seq) print seq}' tmp.fa > zotus.fa
    rm tmp.fa

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        vsearch: \$(vsearch --version 2>&1 | head -n 1 | sed 's/vsearch //g' | sed 's/,.*//g' | sed 's/^v//' | sed 's/_.*//')
    END_VERSIONS
    """
}
