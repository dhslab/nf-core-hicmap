process pairs2hic {
    tag "$meta.id"
    label 'process_high'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'ghcr.io/dhslab/docker-juicer' :
        'ghcr.io/dhslab/docker-juicer' }"

    input:

        tuple val(meta), path (pairs)
        path (chromsizes)

    output:
        tuple val(meta), path ("*.hic")  , emit: hic
        path ("versions.yml")              , emit: versions

    script:
        def args = task.ext.args ?: ''
        """
        mkdir -p tmp
        java -Xmx${task.memory.toGiga()}g  -Djava.awt.headless=true -jar /opt/juicer/juicer_tools_1.22.01.jar pre \\
        $args \\
        -r ${params.resolutions} \\
        -t tmp \\
        --threads ${task.cpus} \\
        $pairs \\
        ${meta.id}.hic \\
        $chromsizes

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            juicer: Unknown
        END_VERSIONS
        """
}
