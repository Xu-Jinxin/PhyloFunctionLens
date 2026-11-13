process GTDB_SELECT_REP {
    tag "gtdb_select_rep"
    label "gtdb_select_rep"

    publishDir "${params.outdir}/PhyloFunctionLens/", mode: 'symlink'

    input:
    path fetch_script, stageAs: 'fetch_rep_genome.sh'

    // Runs first and independently of the user genomes: it only needs
    // --taxon / --level / --outgroup_taxon.
    output:
    path "gtdb_rep_genomes/representative_genome.tsv", emit: gtdb_rep_genomes_list
    path "gtdb_rep_genomes/*_genomic.fna.gz", emit: gtdb_genomes

    script:
    """
    bash fetch_rep_genome.sh \
        -m ${params.gtdb_auxillary_metadata} \
        -g ${params.gtdbtk_genome} \
        -t "${params.taxon}" \
        -r "${params.level}" \
        -o gtdb_rep_genomes
    """

    stub:
    """
    mkdir -p gtdb_rep_genomes
    printf 'RS_GCF_000000001.1\td__Bacteria;p__Test;c__Test;o__Test;f__Test;g__Test;s__Test\t100\t99\tg__Test\tingroup\n' \
        > gtdb_rep_genomes/representative_genome.tsv
    printf 'RS_GCF_000000002.1\td__Bacteria;p__Test2;c__Test2;o__Test2;f__Test2;g__Test2;s__Test2\t90\t95\tg__Test2\toutgroup\n' \
        >> gtdb_rep_genomes/representative_genome.tsv
    printf '>RS_GCF_000000001.1 test\nACGTACGT\n' | gzip -c \
        > gtdb_rep_genomes/RS_GCF_000000001.1_genomic.fna.gz
    printf '>RS_GCF_000000002.1 test\nACGTACGT\n' | gzip -c \
        > gtdb_rep_genomes/RS_GCF_000000002.1_genomic.fna.gz
    """
}
