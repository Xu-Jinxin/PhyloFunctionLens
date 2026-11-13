process PREP_REP_GENOMES {
    tag "${genome_file.name}"
    label "prep_rep_genomes"

    publishDir "${params.outdir}/PhyloFunctionLens/", mode: 'symlink'

    input:
    path genome_file

    output:
    path "rep_genomes/*", emit: rep_genome

    script:
    """
    set -euo pipefail
    mkdir -p rep_genomes

    base=\$(basename "${genome_file}")

    case "\${base}" in
        *_genomic.fna.gz)
            id="\${base%_genomic.fna.gz}"
            reader="zcat"
            ;;
        *.gz)
            id="\${base%.gz}"
            id="\${id%.*}"
            reader="zcat"
            ;;
        *)
            id="\${base%.*}"
            reader="cat"
            ;;
    esac

    \${reader} "${genome_file}" | \
        seqkit replace -p '.+' -r "\${id}__seq{nr}" \
        > "rep_genomes/\${id}.${params.genome_extension}"
    
    echo "[prep_rep_genomes] \${base} -> rep_genomes/\${id}.${params.genome_extension}" >&2
    """

    stub:
    """
    mkdir -p rep_genomes
    touch "rep_genomes/${genome_file.baseName}.${params.genome_extension}"
    """
}
