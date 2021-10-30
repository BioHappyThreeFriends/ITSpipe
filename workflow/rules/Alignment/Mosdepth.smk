ruleorder: bowtie2_map > mosdepth

rule mosdepth:
    input:
        mosdepth_dir_path / "{sample_id}/{sample_id}.sorted.mkdup.bam",
        # bam_clipped=rules.bamutil_clipoverlap.output.bam_clipped
        # bai=rules.index_bam.output
    output:
        mosdepth_dir_path / "{sample_id}/{sample_id}.coverage.per-base.bed.gz"
    params:
        min_mapping_quality=config["mosdepth_min_mapping_quality"],
        output_pefix=mosdepth_dir_path / "{sample_id}/{sample_id}.coverage"
    log:
        std=log_dir_path / "{sample_id}/mosdepth.log",
        cluster_log=cluster_log_dir_path / "{sample_id}.mosdepth.cluster.log",
        cluster_err=cluster_log_dir_path / "{sample_id}.mosdepth.cluster.err"
    benchmark:
         benchmark_dir_path / "{sample_id}/mosdepth.benchmark.txt"
    conda:
        "../../../%s" % config["conda_config"]
    resources:
        cpus=config["mosdepth_threads"],
        time=config["mosdepth_time"],
        mem=config["mosdepth_mem_mb"],
    threads:
        config["mosdepth_threads"]
    shell:
        "mosdepth -t {threads} --mapq {params.min_mapping_quality} {params.output_pefix} {input} > {log.std} 2>&1"