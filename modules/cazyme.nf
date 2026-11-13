 process CAZYME {
    tag "cazyme"
    label "cazyme"

    publishDir "${params.outdir}/PhyloFunctionLens/", mode: 'symlink'

    input:
    path clean_OG

    output:
    path "cazyme", emit: cazyme_dir

    script:
    def container_db_path = "/opt/dbcan_db"
    """
    run_dbcan CAZyme_annotation \
        --input_raw_data ${clean_OG} \
        --mode protein \
        --output_dir cazyme  \
        --db_dir ${container_db_path}
    """

    stub:
    """
    mkdir -p cazyme
    """
}