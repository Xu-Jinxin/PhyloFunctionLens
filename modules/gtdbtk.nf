process GTDBTK {
    tag "gtdbtk"
    label "gtdbtk"

    publishDir "${params.outdir}/PhyloFunctionLens/", mode: 'symlink'

    input:
    path 'input_genomes/*'

    output:
    path "gtdbtk", emit: gtdbtk_dir
    path "gtdbtk/align/gtdbtk.*.user_msa.fasta.gz", emit: user_msa

    script:
    """
    export GTDBTK_DATA_PATH='/opt/gtdbtk_db'
    gtdbtk classify_wf \
        --genome_dir input_genomes \
        --out_dir  gtdbtk \
        --place_species \
        --extension "${params.genome_extension}" \
        --cpus "${task.cpus}" --force
    """

    stub:
    """
    mkdir -p gtdbtk/align
    touch gtdbtk/align/gtdbtk.bac120.user_msa.fasta.gz
    """

}