import os

configfile: "PhyPredi_config.yaml"

ref_basename=os.path.splitext(os.path.basename(config["pep_file"]))[0]

rule all:
    input:
        f"results/{ref_basename}_phytocytokine.txt"

rule file_treatment:
    input:
        pep_file=config["pep_file"]
    output:
        temp(f"{ref_basename}_treated.fasta")
    log:
        f"logs/{ref_basename}_file_treatment.log"
    shell:
        r"""
        seqkit replace \
        -p "\s.+" \
        {input.pep_file} \
        | sed 's/\*$//' \
        1> {output} \
        2> {log}
        """

rule length_filter:
    input:
        pep_file=f"{ref_basename}_treated.fasta"
    output:
        f"{ref_basename}_shortpep.fasta"
    params:
        max_length=config["max_length"]
    log:
        "logs/length_filter.log"
    shell:
        """
        seqkit seq \
        -M {params.max_length} \
        {input.pep_file} \
        1> {output[0]} \
        2> {log}
        """

rule Prediction_Phobius:
    input:
        pep_file=f"{ref_basename}_shortpep.fasta"
    output:
        f"results/Phobius/{ref_basename}_Phobius.txt"
    log:
        "logs/Prediction_Phobius.log"
    shell:
        """
        phobius.pl \
        -short {input.pep_file} \
        | sed '1s/SEQENCE //' \
        | awk 'BEGIN {{OFS="\\t"}} {{print $1, $2, $3, $4}}' \
        1> {output} \
        2> {log}
        """

rule NoTM_shortpep_extraction:
    input:
        pep_file=f"{ref_basename}_shortpep.fasta",
        Phobius_file=f"results/Phobius/{ref_basename}_Phobius.txt"
    output:
        NoTM_shortpep_list=f"{ref_basename}_shortpep_NoTM.list",
        NoTM_shortpep_file=f"{ref_basename}_shortpep_NoTM.fasta"
    shell:
        """
        awk -F "\\t" '$2 == "0" {{print $1}}' {input.Phobius_file} > {output.NoTM_shortpep_list}

        seqkit grep -f {output.NoTM_shortpep_list} {input.pep_file} 1> {output.NoTM_shortpep_file}
        """

rule Prediction_signalP:
    input:
        pep_file=f"{ref_basename}_shortpep_NoTM.fasta"
    output:
        "results/signalP/output.gff3"
    params:
        "results/signalP/"
    conda:
        config["conda_env"]
    log:
        "logs/Prediction_signalP.log"
    shell:
        """
        signalp6 \
	    --fastafile {input} \
	    --output_dir {params} \
	    --format txt \
	    --organism eukarya \
	    --mode slow-sequential \
        2> {log}
        """

rule Prediction_Predisi:
    input:
        pep_file=f"{ref_basename}_shortpep_NoTM.fasta"
    output:
        f"results/Predisi/{ref_basename}_Predisi.txt"
    params:
        predisi_folder=config["predisi_folder"]
    log:
        "logs/Prediction_Predisi.log"
    shell:
        """
        java -cp {params.predisi_folder} \
        JSPP {params.predisi_folder}/matrices/eukarya.smx {input} {output} \
        2> {log}
        """

rule Phytocytokine_candidate_extraction:
    input:
        Phobius_file=f"results/Phobius/{ref_basename}_Phobius.txt",
        signalP_file="results/signalP/output.gff3",
        Predisi_file=f"results/Predisi/{ref_basename}_Predisi.txt"
    output:
        Phobius_candidate=f"results/Phobius/{ref_basename}_Phobius_candidate.txt",
        signalP_candidate=f"results/signalP/{ref_basename}_signalP_candidate.txt",
        Predisi_candidate=f"results/Predisi/{ref_basename}_Predisi_candidate.txt"
    shell:
        """
        awk -F "\t" '$3 == "Y" {print $1}' {input.Phobius_file} > {output.Phobius_candidate}
        awk -F "\t" '$3 == "signal_peptide" {print $1}' {input.signalP_file} > {output.signalP_candidate}
        awk -F "\t" '$3 == "Y" {print $1}' {input.Predisi_file} > {output.Predisi_candidate}
        """

rule Extract_common_candidates:
    input:
        Phobius_candidate=f"results/Phobius/{ref_basename}_Phobius_candidate.txt",
        signalP_candidate=f"results/signalP/{ref_basename}_signalP_candidate.txt",
        Predisi_candidate=f"results/Predisi/{ref_basename}_Predisi_candidate.txt"
    output:
        common_candidates=f"results/{ref_basename}_phytocytokine.txt"
    shell:
        """
        awk 'FNR==NR {a[$1]++; next} {a[$1]++} END {for (i in a) if (a[i] >= 2) print i}' {input.Phobius_candidate} {input.signalP_candidate} {input.Predisi_candidate} > {output.common_candidates}
        """