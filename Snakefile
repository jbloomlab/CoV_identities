"""``snakemake`` file that runs analysis.

Written by Jesse Bloom.

"""


configfile: "config.yaml"


rule all:
    input:
        expand("results/viruses/NGDC/{virus}.fasta", virus=config["viruses"]["NGDC"]),
        expand("results/viruses/Genbank/{virus}.fasta", virus=config["viruses"]["Genbank"]),
        expand("results/viruses/GISAID/{virus}.fasta", virus=config["viruses"]["GISAID"]),


rule get_ngdc_fasta:
    """Get FASTA file from NGDC."""
    output:
        fasta="results/viruses/NGDC/{virus}.fasta",
    params:
        accession=lambda wc: config["viruses"]["NGDC"][wc.virus],
    shell:
        "wget --no-check-certificate -O - {params.accession} | gzip -cd > {output.fasta}"


rule get_genbank_fasta:
    """Get FASTA file from Genbank."""
    output:
        fasta="results/viruses/Genbank/{virus}.fasta",
    params:
        accession=lambda wc: config["viruses"]["Genbank"][wc.virus],
    shell:
        "efetch -format fasta -db nuccore -id {params.accession} > {output.fasta}"


rule get_gisaid_fasta:
    """Copy GISAID FASTA to results directory."""
    input:
        fasta=lambda wc: config["viruses"]["GISAID"][wc.virus],
    output:
        fasta="results/viruses/GISAID/{virus}.fasta",
    shell:
        "cp {input.fasta} {output.fasta}"

