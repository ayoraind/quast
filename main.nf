#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// include non-process modules
include { help_message; version_message; complete_message; error_message; pipeline_start_message } from './modules/messages.nf'
include { default_params; check_params } from './modules/params_parser.nf'
include { help_or_version } from './modules/params_utilities.nf'

version = '1.0dev'

// setup default params
default_params = default_params()
// merge defaults with user params
merged_params = default_params + params

// help and version messages
help_or_version(merged_params, version)
final_params = check_params(merged_params)
// starting pipeline
pipeline_start_message(version, final_params)

// include processes
include { QUAST; QUAST_SUMMARY } from './modules/processes.nf' addParams(final_params)

workflow {

          assemblies_ch = channel
                                .fromPath( final_params.assemblies, checkIfExists: true )
                                .map { file -> tuple(file.simpleName, file) }

	 QUAST(assemblies_ch)
	 
         collected_quaststatistics_ch = QUAST.out.quast_transposed_report_ch.collect( sort: {a, b -> a[0].getBaseName() <=> b[0].getBaseName()} )

         QUAST_SUMMARY(collected_quaststatistics_ch, final_params.sequencing_date)

}

workflow.onComplete {
    complete_message(final_params, workflow, version)
}

workflow.onError {
    error_message(workflow)
}
