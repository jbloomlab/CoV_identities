# # Gene identities among SARS-related coronaviruses and SARS-CoV-2 variants

This repository generates a heatmap that shows the percent nucleotide identity for genes among different coronaviruses.
That heatmap is rendered interactively at [https://jbloomlab.github.io/CoV_identities/identities.html](https://jbloomlab.github.io/CoV_identities/identities.html).

The code to generate the heatmap is run by a `snakemake` pipeline in [Snakefile](Snakefile) in this repository.
To run the code, first build and activate the conda environment in [environment.yml](environment.yml), and then simply run `snakemake -j 1`.

The pipeline works by obtaining the full genomes for the coronaviruses specified in [config.yaml](config.yaml).
It then builds a full-genome multiple-sequence alignment, and computes percent identities for each gene using the gene boundaries defined in [config.yaml](config.yaml).

It then uses `altair` to generate an interactive heatmap which is rendered via GitHub pages.

The numerical data in the heatmap are in [results/identities/identities.csv](results/identities/identities.csv).

The code is written by Jesse Bloom.
