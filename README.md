<img src="https://github.com/user-attachments/assets/c1778e95-639c-494f-8550-552cde5c5a8e" alt="pipeline" width="200" height="225">

## 1. Dependent Software

- Java
- [seqkit](https://bioinf.shenwei.me/seqkit/)
- [SignalP6](https://services.healthtech.dtu.dk/services/SignalP-6.0/)
- [Predisi](http://predisi.de/)
- [Phobius](https://phobius.sbc.su.se/)

## 2. What to input

- Protein sequence fasta file (primary transcripts only)

## 3. What to output

- Signal peptides prediction results from three softwares
- Final phytocytokine candidates

## 4. Usage

```shell
snakemake \
	--snakefile PhyPredi.smk \
	--use-conda \
	--rerun-incomplete \
	--nolock
```