<img src="https://github.com/user-attachments/assets/c1778e95-639c-494f-8550-552cde5c5a8e" alt="pipeline" width="300" height="337.5">

## 1. Dependent Software

- Java
- [seqkit](https://bioinf.shenwei.me/seqkit/)
- [SignalP6](https://services.healthtech.dtu.dk/services/SignalP-6.0/)
- [Predisi](http://predisi.de/)
- [Phobius](https://phobius.sbc.su.se/)

## 2. What to input

- When primary transcripts only protein sequence fasta file provided, add protein file.
- When primary transcripts only file are not provided, add genome file and annotation file.

gzipped files are supported.

## 3. What to output

- Signal peptides prediction results from three softwares
- Final phytocytokine candidates

## 4. Usage

```shell
snakemake \
	--snakefile PhyPredi.smk \
	--use-conda \
	--use-singularity \
	--rerun-incomplete \
	--nolock
```