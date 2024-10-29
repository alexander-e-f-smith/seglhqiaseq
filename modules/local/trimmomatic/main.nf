process trimmomatic {
    tag "$meta.id"
    label 'process_single'
    container "docker.io/seglh/legacy_pr_snappy_trimmomatic:4.0.0"


    input:
    tuple val(meta), path(fastq)
    path (adapters)


    output:
    tuple val(meta), path("*{filtered,metrics}.{fq.gz,READS}")  , emit: filtered_fastq
    tuple val(meta), path("*{unpaired}.{fq.gz}")                , optional:true, emit: unpaired_fastq
    path "versions.yml"                                         , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:


    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def trimmomatic ="/usr/local/pipeline/Trimmomatic-0.32/trimmomatic-0.32.jar"
    def out_fastq_files = "${prefix}_1_filtered.fq.gz ${prefix}_1_unpaired.fq.gz ${prefix}_2_filtered.fq.gz ${prefix}_2_unpaired.fq.gz"
    def out_metrics_file = "${prefix}_metrics.READS"

    """
    java -Xmx4G -jar $trimmomatic \\
        PE -trimlog /dev/stdout  \\
        -threads 4 \\
        $fastq \\
        ${out_fastq_files} \\
        ILLUMINACLIP:${adapters}:2:30:10:1:true MINLEN:36



    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        trimmomatic: \$( ls /usr/local/pipeline/Trimmomatic*/trimmomatic*.jar )
        java_env: \$(echo \$( java -version 2>&1) | head -c 24 | sed -e "s/\\"//g" | sed -e "s/ /_/g" )
    END_VERSIONS
    """
}

/*
.....................
process old_trim{

    output = params.out_dir

    tag { [run, readgroup].join(':') }
    publishDir "${output}/${readgroup}", mode:"copy"
    label "bigger_cpu"

    input:
    tuple val(run), val(readgroup), path(reads)
    path adapters
    path(scripts)

    output:
    tuple val(run), val(readgroup), path("${readgroup}_*{filtered,metrics}.{fq.gz,READS}")
    stdout emit: trimlogging

    script:
    def out_fastq_files = "${readgroup}_1_filtered.fq.gz ${readgroup}_1_rubbish_filtered.fq.gz ${readgroup}_2_filtered.fq.gz ${readgroup}_2_rubbish_filtered.fq.gz"
    def out_metrics_file = "${readgroup}_metrics.READS"
    def (r1, r2) = reads
    def py = "${params.python2}"

    """
    java -Xmx4G -jar /usr/local/pipeline/Trimmomatic-0.32/trimmomatic-0.32.jar \\
        PE -trimlog /dev/stdout  \\
        -threads 4 \\
        ${r1} \\
        ${r2} \\
        ${out_fastq_files} \\
        ILLUMINACLIP:${adapters}:2:30:10:1:true MINLEN:36 \\
        | ${py} parseTrimlog.py > ${out_metrics_file}
    """
}

*/
