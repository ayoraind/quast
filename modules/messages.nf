def help_message() {
  log.info """
        Usage:
        The typical command for running the pipeline is as follows:
        nextflow run main.nf --output_dir "PathToOutputDir" --assemblies "PathToAssemblies" --sequencing_date 'GYYMMDD' 

        Mandatory arguments:
         --assemblies                   must be Flye assembly (e.g., "/MIGE/01_DATA/03_ASSEMBLY/*_FLYE/T055-8-*.fasta").
         --output_dir	                Output directory
         --sequencing_date              Sequencing date (e.g. G220902)

        Optional arguments:
         --help                         This usage statement.
         --version                      Version statement
        """
}


def version_message(String version) {
      println(
            """
            ============================================================
                 POST-ASSEMBLY QC: TAPIR Pipeline version ${version}
            ============================================================
            """.stripIndent()
        )

}


def pipeline_start_message(String version, Map params){
    log.info "======================================================================"
    log.info "    POST-ASSEMBLY QC: TAPIR Pipeline version ${version}"
    log.info "======================================================================"
    log.info "Running version   : ${version}"
    log.info "Fasta inputs      : ${params.assemblies}"
    log.info ""
    log.info "-------------------------- Other parameters --------------------------"
    params.sort{ it.key }.each{ k, v ->
        if (v){
            log.info "${k}: ${v}"
        }
    }
    log.info "======================================================================"
    log.info "Outputs written to path '${params.output_dir}'"
    log.info "======================================================================"

    log.info ""
}


def complete_message(Map params, nextflow.script.WorkflowMetadata workflow, String version){
    // Display complete message
    log.info ""
    log.info "Ran the workflow: ${workflow.scriptName} ${version}"
    log.info "Command line    : ${workflow.commandLine}"
    log.info "Completed at    : ${workflow.complete}"
    log.info "Duration        : ${workflow.duration}"
    log.info "Success         : ${workflow.success}"
    log.info "Work directory  : ${workflow.workDir}"
    log.info "Exit status     : ${workflow.exitStatus}"
    log.info ""
}

def error_message(nextflow.script.WorkflowMetadata workflow){
    // Display error message
    log.info ""
    log.info "Workflow execution stopped with the following message:"
    log.info "  " + workflow.errorMessage
}
