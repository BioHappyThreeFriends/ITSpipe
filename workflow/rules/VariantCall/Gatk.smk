rule gatk_mutect2:
    input:
        reference=reference,
        dict=rules.picard_dict.output,
        fai=rules.samtools_faidx.output,
        samples=expand(clipped_alignment_dir_path / "{sample_id}/{sample_id}.sorted.mkdup.clipped.view.bam", sample_id=config["sample_id"]),
        indexes=expand(clipped_alignment_dir_path / "{sample_id}/{sample_id}.sorted.mkdup.clipped.view.bam.bai", sample_id=config["sample_id"])
    output:
        varcall_gatk_dir_path / "{reference_basename}.mutect2.vcf.gz"
    log:
        std=log_dir_path / "{reference_basename}.gatk_mutect2.log",
        cluster_log=cluster_log_dir_path / "{reference_basename}.gatk_mutect2.cluster.log",
        cluster_err=cluster_log_dir_path / "{reference_basename}.gatk_mutect2.cluster.err"
    benchmark:
        benchmark_dir_path / "{reference_basename}.gatk_mutect2.benchmark.txt"
    conda:
        "../../../%s" % config["conda_config"]
    resources:
        cpus=config["gatk_mutect2_threads"],
        mem=config["gatk_mutect2_mem_mb"],
        time=config["gatk_mutect2_time"]
    threads:
        config["gatk_mutect2_threads"]
    shell:
        "gatk --java-options '-Xmx{resources.mem}m' Mutect2 -R {input.reference} -I test.lst -O {output}"