process BAKTA {
    tag "bakta"
    label "bakta"

    publishDir "${params.outdir}/PhyloFunctionLens/", mode: 'symlink'

    input:
    path clean_OG

    output:
    path "bakta", emit: bakta_dir
    path "bakta/OG.json", emit: bakta_json

    script:
    def container_db_path = '/opt/bakta_db'
    """
    bakta_proteins \
        --db ${container_db_path} \
        --output bakta \
        "${clean_OG}"
    """

    stub:
    """
    mkdir -p bakta
    """

}