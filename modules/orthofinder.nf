process ORTHOFINDER {
    tag "orthofinder"
    label "orthofinder"

    publishDir "${params.outdir}/PhyloFunctionLens/", mode: 'symlink'

    input:
    path "input_proteins/*"
    path "species_tree.nwk"

    output:
    path "orthofinder/Results_*/MultipleSequenceAlignments", emit: og_dir
    path "orthofinder/Results_*/Resolved_Gene_Trees/Resolved_Gene_Trees.txt", emit: gene_trees

    script:
    """
    orthofinder \
        -f input_proteins \
        -M msa -S mmseqs -A mafft -T fasttree_fastest \
        -t ${task.cpus} \
        -X \
        -s species_tree.nwk \
        -o orthofinder
    """

    stub:
    """
    mkdir -p orthofinder/Results_date/MultipleSequenceAlignments
    touch orthofinder/Results_date/MultipleSequenceAlignments/OG{0000000..0000010}.fa
    touch orthofinder/Results_date/Orthogroups/Orthogroups.GeneCount.tsv

    """
}

process OG_PROCESS {
    tag "OG_process"
    label "OG_process"

    publishDir "${params.outdir}/PhyloFunctionLens/", mode: 'symlink'

    input:
    path "MultipleSequenceAlignments"
    path "Resolved_Gene_Trees.tsv"

    output:
    path "OGfilter/*.fa", emit: filtered_OG
    path "OG.fa", emit: clean_OG
    path "OG_seq_map.tsv", emit: og_seq_map

    script:
    """
    rm -rf OG.fa
    mkdir -p OGfilter
    printf "OG\tSeqID\n" > OG_rep_map.tsv

    awk '/^OG[0-9]+:/ { n = \$1; sub(":", "", n); print n}' Resolved_Gene_Trees.tsv | \
        while read OG; do 
            seqkit shuffle -s 11 "MultipleSequenceAlignments/\${OG}.fa" | \
                seqkit head -n 1 | \
                seqkit seq --remove-gaps >> OG.fa

            seqkit seq -n -i "MultipleSequenceAlignments/\${OG}.fa" | \
                awk -v og="\${OG}" 'BEGIN{OFS="\t"}{print og, \$0}' >> OG_seq_map.tsv
            cp MultipleSequenceAlignments/\${OG}.fa OGfilter/
        done

    """

    stub:
    """
    mkdir -p OGfilter; touch OGfilter/OG{001..010}.fa
    touch OG.fa OG_seq_map.tsv
    mkdir -p gene_trees; touch gene_trees/OG{001..010}.tre

    """
}