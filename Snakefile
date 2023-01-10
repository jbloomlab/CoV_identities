"""``snakemake`` file that runs analysis.

Written by Jesse Bloom.

"""


configfile: "config.yaml"


rule all:
    input:
        "results/viruses/all_viruses_aligned.fasta",


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


rule concat_fastas:
    """Concatenate all the virus sequences into a FASTA file."""
    input:
        fastas=[
            f"results/viruses/{db}/{virus}.fasta"
            for db in config["viruses"] for virus in config["viruses"][db]
        ],
    output:
        fasta="results/viruses/all_viruses.fasta",
    shell:
        # https://askubuntu.com/a/640062
        "awk 1 {input.fastas} > {output.fasta}"


rule align:
    """Align all viruses."""
    input:
        fasta=rules.concat_fastas.output.fasta,
    output:
        fasta="results/viruses/all_viruses_aligned.fasta",
    shell:
        "mafft {input.fasta} > {output.fasta}"
