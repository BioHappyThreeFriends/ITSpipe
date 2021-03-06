rule gatk_mutect2:
    input:
        reference=reference,
        dict=rules.picard_dict.output,
        fai=rules.samtools_faidx.output,
        sample=clipped_alignment_dir_path / "{sample_id}/{sample_id}.clipped.bam",
        index=clipped_alignment_dir_path / "{sample_id}/{sample_id}.clipped.bam.bai"
    output:
        vcf=varcall_gatk_dir_path / "{sample_id}/{sample_id}.mutect2.vcf.gz",
        stats=varcall_gatk_dir_path / "{sample_id}/{sample_id}.mutect2.vcf.gz.stats",
        tbi=varcall_gatk_dir_path / "{sample_id}/{sample_id}.mutect2.vcf.gz.tbi"
    params:
        options=config["gatk_mutect2_options"]
    log:
        std=log_dir_path / "{sample_id}/gatk_mutect2.log",
        cluster_log=cluster_log_dir_path / "{sample_id}/gatk_mutect2.cluster.log",
        cluster_err=cluster_log_dir_path / "{sample_id}/gatk_mutect2.cluster.err"
    benchmark:
        benchmark_dir_path / "{sample_id}/gatk_mutect2.benchmark.txt"
    conda:
        "../../../%s" % config["conda_config"]
    resources:
        cpus=config["gatk_mutect2_threads"],
        mem=config["gatk_mutect2_mem_mb"],
        time=config["gatk_mutect2_time"]
    threads:
        config["gatk_mutect2_threads"]
    shell:
        "gatk --java-options '-Xmx{resources.mem}m' Mutect2 {params.options} -R {input.reference} -I {input.sample} "
        "-O {output.vcf} 1> {log.std} 2>&1 "


rule bcftools_merge_gatk_vcfs:
    input:
        expand(varcall_gatk_dir_path / "{sample_id}/{sample_id}.mutect2.vcf.gz", sample_id=config["sample_id"])
    output:
        varcall_gatk_dir_path / gatk_merged_vcf_filename
    log:
        std=log_dir_path / "bcftools_merge_gatk_vcfs.log",
        cluster_log=cluster_log_dir_path / "bcftools_merge_gatk_vcfs.cluster.log",
        cluster_err=cluster_log_dir_path / "bcftools_merge_gatk_vcfs.cluster.err"
    benchmark:
        benchmark_dir_path / "bcftools_merge_gatk_vcfs.benchmark.txt"
    conda:
        "../../../%s" % config["conda_config"]
    resources:
        cpus=config["bcftools_merge_threads"],
        mem=config["bcftools_merge_mem_mb"],
        time=config["bcftools_merge_time"]
    threads:
        config["bcftools_merge_threads"]
    shell:
        "bcftools merge {input} | gzip -c > {output} 2> {log.std}"