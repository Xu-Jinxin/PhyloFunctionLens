process GTDB_TREE {
    tag "gtdb_tree"
    label "gtdb_tree"

    publishDir "${params.outdir}/PhyloFunctionLens/", mode: 'symlink'

    input:
    path split_bipartition_script, stageAs: 'split_bipartition.sh'
    path user_msa
    path gtdb_rep_genomes_list

    output:
    path "species_rooted.nwk", emit: species_tree

    script:
    def container_db_path = '/opt/gtdb_tree_db'

    """
    lineage=\$(head -n1 "${gtdb_rep_genomes_list}" | cut -f2)

    domain=\${lineage%%;*}
    case "\$domain" in
        d__Bacteria) marker=bac120 ;;
        d__Archaea)  marker=ar53   ;;
        *) echo "Error: cannot determine domain from '\${lineage}'" >&2; exit 1 ;;
    
    esac

    cut -f1 "${gtdb_rep_genomes_list}" > node.temp
    nw_prune -v "${container_db_path}/\${marker}_r232.tree" -f node.temp  > subtree.nwk
    outgroup=\$(bash ./split_bipartition.sh subtree.nwk)

    seqkit grep -f node.temp "${container_db_path}/\${marker}_msa_reps_r232.faa.gz" -o gtdbtk.\${marker}.msa.fasta.gz
    cat ${user_msa} gtdbtk.\${marker}.msa.fasta.gz > gtdbtk.\${marker}.whole.user.msa.fasta.gz

    iqtree \
        -s gtdbtk.\${marker}.whole.user.msa.fasta.gz \
        -g subtree.nwk \
        -m LG+I+G \
        -B 1000 \
        -T ${task.cpus} \
        --prefix species
    
    nw_reroot species.treefile \${outgroup} > species_rooted.nwk

    """

    stub:
    """
    touch species_rooted.nwk
    """

}
