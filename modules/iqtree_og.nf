process IQTREE_OG {
    tag "iqtree_og"
    label "iqtree_og"
    errorStrategy 'ignore'

    publishDir "${params.outdir}/gencomp/", mode: 'symlink'

    input:
    tuple val(id), path(og)

    output:
    path "iqtree_og/${id}.ufboot", emit: iqtree_og_tree, optional: true

    script:
    """
    mkdir -p iqtree_og
    
    nuniq=\$(awk '/^>/{if(seq!=""){print seq}; seq=""; next}{seq=seq\$0} END{if(seq!="")print seq}' ${og} | sort -u | wc -l)
    if [ "\$nuniq" -lt 4 ]; then
        echo "OG ${id} has only \$nuniq unique sequences, skip IQ-TREE."
        exit 0
    fi

    iqtree -m LG+I+G -s ${og} --prefix iqtree_og/${id} -T ${task.cpus} --ufboot 1000 -wbtl -nstop 20

    """

    stub:
    """
    touch ${id}.ufboot
    """

}