from pathlib import Path
import os


#---- setup config ----
configfile: "config/default.yaml"

#---- setup paths ----
cluster_log_dir_path = Path(config["cluster_log_dir"])
log_dir_path = Path(config["log_dir"])
benchmark_dir_path = Path(config["benchmark_dir"])
samples_dir_path = Path(config["samples_dir"])
output_dir_path = Path(config["output_dir"])

filtered_reads_dir_path = output_dir_path / config["filtered_read_dir"]
raw_alignment_dir_path = output_dir_path / config["raw_alignment_dir"]
raw_coverage_dir_path = output_dir_path / config["raw_coverage_dir"]
clipped_alignment_dir_path = output_dir_path / config["clipped_alignment_dir"]
clipped_coverage_dir_path = output_dir_path / config["clipped_coverage_dir"]

#---- setup filenames ----
reference = Path(config["reference"])
reference_dir_path = reference.parents[0]
reference_filename = reference.name
reference_basename = reference.stem

if "sample_id" not in config:
    config["sample_id"] = [d.name for d in samples_dir_path.iterdir() if d.is_dir()]

localrules: all

rule all:
    input:
        # Trimmomatic:
        expand(filtered_reads_dir_path / "{sample_id}/{sample_id}.trimmed_1.fastq.gz", sample_id=config["sample_id"]),
        expand(filtered_reads_dir_path / "{sample_id}/{sample_id}.trimmed_1.se.fastq.gz", sample_id=config["sample_id"]),
        expand(filtered_reads_dir_path / "{sample_id}/{sample_id}.trimmed_2.fastq.gz", sample_id=config["sample_id"]),
        expand(filtered_reads_dir_path / "{sample_id}/{sample_id}.trimmed_2.se.fastq.gz", sample_id=config["sample_id"]),

        # Bowtie2:
        expand(raw_alignment_dir_path / "{sample_id}/{sample_id}.sorted.mkdup.bam", sample_id=config["sample_id"]),

        # Bamutil:
        expand(clipped_alignment_dir_path / "{sample_id}/{sample_id}.sorted.mkdup.clipped.bam", sample_id=config["sample_id"]),

        # Mosdepth:
        expand(raw_coverage_dir_path / "{sample_id}.coverage.per-base.bed.gz", sample_id=config["sample_id"]),
        expand(clipped_coverage_dir_path / "{sample_id}.clipped.coverage.per-base.bed.gz", sample_id=config["sample_id"]),

        # Coverage visualization:
        expand(raw_coverage_dir_path / "{sample_id}.png", sample_id=config["sample_id"]),
        expand(raw_coverage_dir_path / "{sample_id}.svg", sample_id=config["sample_id"]),
        expand(clipped_coverage_dir_path / "{sample_id}.clipped.png", sample_id=config["sample_id"]),
        expand(clipped_coverage_dir_path / "{sample_id}.clipped.svg", sample_id=config["sample_id"]),

#---- load rules ----
include: "workflow/rules/QCFiltering/Trimmomatic.smk"
include: "workflow/rules/Alignment/Bowtie2.smk"
include: "workflow/rules/Alignment/Samtools.smk"
include: "workflow/rules/Alignment/Mosdepth.smk"
include: "workflow/rules/QCFiltering/Bamutil.smk"
include: "workflow/rules/Visualization/Coverage.smk"

