
nw_prune -v ../../assets/ar53_r232.tree -f node.temp > subtree.nwk

seqkit grep -f node.temp ../../assets//ar53_msa_reps_r232.faa.gz -o gtdbtk.ar53.msa.fasta.gz
cat PhyloFunctionLens/gtdbtk/align/gtdbtk.ar53.user_msa.fasta.gz gtdbtk.ar53.msa.fasta.gz > gtdbtk.ar53.whole.user.msa.fasta.gz

iqtree \
    -s gtdbtk.ar53.whole.user.msa.fasta.gz \
    -g subtree.nwk \
    -m LG+F+R5 \
    -B 1000 --alrt 1000 \
    -T 8 \
    --prefix species

lineage=$(head -n1 PhyloFunctionLens/gtdb_rep_genomes/representative_genome.tsv | cut -f2)

domain=${lineage%%;*}
case "$domain" in
    d__Bacteria) marker=bac120 ;;
    d__Archaea)  marker=ar53   ;;
    *) echo "Error: cannot determine domain from '${lineage}'" >&2; exit 1 ;;
esac

cut -f1 PhyloFunctionLens/gtdb_rep_genomes/representative_genome.tsv > node.temp
nw_prune -v /home/xujinxin/project/20261104_PhyloFunctionLens/assets/${marker}_r232.tree -f node.temp > subtree.nwk

seqkit grep -f node.temp ~/database/gtdb_r232/${marker}_msa_reps_r232.faa.gz -o gtdbtk.${marker}.msa.fasta.gz
cat PhyloFunctionLens/gtdbtk/align/gtdbtk.ar53.user_msa.fasta.gz gtdbtk.${marker}.msa.fasta.gz > gtdbtk.${marker}.whole.user.msa.fasta.gz

iqtree \
    -s gtdbtk.${marker}.whole.user.msa.fasta.gz \
    -g subtree.nwk \
    -m LG+I+G \
    -B 1000 \
    -T 8 \
    --prefix species