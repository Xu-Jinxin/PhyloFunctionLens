#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { GTDB_SELECT_REP } from '../modules/gtdb_select_representative'
include { CHECKM2 } from '../modules/checkm2'
include { FILTER_GENOMES } from '../modules/checkm2'
include { SKDER } from '../modules/skder'
include { PREP_REP_GENOMES } from '../modules/prep_rep_genomes'
include { GTDBTK } from '../modules/gtdbtk'
include { GTDB_TREE } from '../modules/gtdb_tree'

workflow stage_1 {
    take:
    genomes_ch

    main:

    GTDB_SELECT_REP(file("${projectDir}/bin/fetch_rep_genome.sh"))
    
    if (params.input) {

        CHECKM2(genomes_ch)
        FILTER_GENOMES(CHECKM2.out.checkm2_dir, genomes_ch)
        SKDER(FILTER_GENOMES.out.genomes_dir)
        GTDBTK(SKDER.out.drep_genomes)
        GTDB_TREE(file("${projectDir}/bin/split_bipartition.sh"), GTDBTK.out.user_msa, GTDB_SELECT_REP.out.gtdb_rep_genomes_list)   

        all_genomes_ch = GTDB_SELECT_REP.out.gtdb_genomes
            .mix(SKDER.out.drep_genomes)
            .collect()
            
        PREP_REP_GENOMES(all_genomes_ch.flatten())
        
        rep_genomes_ch = PREP_REP_GENOMES.out.rep_genome
            .collect()
        user_reps_ch = SKDER.out.drep_genomes
        checkm2_ch = CHECKM2.out.quality_report

    } else {

        all_genomes_ch = GTDB_SELECT_REP.out.gtdb_genomes

        PREP_REP_GENOMES(all_genomes_ch.flatten())

        user_msa_ch = Channel.fromPath("${projectDir}/assets/empty_user_msa.fasta")
        GTDB_TREE(file("${projectDir}/bin/split_bipartition.sh"), user_msa_ch, GTDB_SELECT_REP.out.gtdb_rep_genomes_list)

        rep_genomes_ch = PREP_REP_GENOMES.out.rep_genome
            .collect()
        user_reps_ch = Channel.empty()
        checkm2_ch = file("${projectDir}/assets/empty_checkm2_report.tsv")

    }


    emit:
    rep_genomes = rep_genomes_ch
    species_root_tree = GTDB_TREE.out.species_tree
    gtdb_rep_genomes_list = GTDB_SELECT_REP.out.gtdb_rep_genomes_list
    checkm2_report=checkm2_ch
}
