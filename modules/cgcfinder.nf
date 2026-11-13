process CGCFINDER {
    tag "${id}"
    label "cgcfinder"

    publishDir "${params.outdir}/PhyloFunctionLens/", mode: 'symlink'

    input:
    tuple val(id), path(genome), path(faa), path(gff), path(gene)

    output:
    path "cgcfinder/${id}", emit: cgc_dir

    script:
    def container_db_path = '/opt/dbcan_db'
    """
    mkdir -p cgcfinder/${id}

    run_dbcan CAZyme_annotation \
        --input_raw_data ${faa} \
        --mode protein \
        --output_dir cgcfinder/${id}  \
        --db_dir ${container_db_path}

    run_dbcan gff_process \
    --input_gff ${gff} \
    --gff_type prodigal \
    --output_dir cgcfinder/${id} \
    --db_dir ${container_db_path} 

    run_dbcan cgc_finder --output_dir cgcfinder/${id}

    run_dbcan substrate_prediction \
        --input_raw_data ${faa} \
        --mode protein \
        --output_dir cgcfinder/${id} \
        --db_dir ${container_db_path}

    run_dbcan cgc_circle_plot \
        --output_dir cgcfinder/${id}
    """

    stub:
    """
    mkdir -p cgcfinder/${id}
    touch cgcfinder/${id}/stub.txt
    """
}