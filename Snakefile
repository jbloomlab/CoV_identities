"""``snakemake`` file that runs analysis.

Written by Jesse Bloom.

"""


import Bio.SeqIO


configfile: "config.yaml"


rule all:
    input:
        "results/identities/identities.html",
        "results/identities/identities.csv",


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
    run:
        seqs = [
            (os.path.splitext(os.path.basename(f))[0], str(Bio.SeqIO.read(f, "fasta").seq))
            for f in input.fastas
        ]
        assert len(seqs) == len(set(tup[0] for tup in seqs))
        with open(output.fasta, "w") as f:
            for head, seq in seqs:
                f.write(f">{head}\n{seq}\n")


rule align:
    """Align all viruses."""
    input:
        fasta=rules.concat_fastas.output.fasta,
    output:
        fasta="results/viruses/all_viruses_aligned.fasta",
    shell:
        "mafft {input.fasta} > {output.fasta}"


rule compute_and_plot_identities:
    input:
        fasta=rules.align.output.fasta,
    output:
        chart="results/identities/identities.html",
        csv="results/identities/identities.csv",
    params:
        alignment_ref=config["alignment_ref"],
        ref_regions=config["ref_regions"],
    notebook:
        "notebooks/compute_and_plot_identities.py.ipynb"
