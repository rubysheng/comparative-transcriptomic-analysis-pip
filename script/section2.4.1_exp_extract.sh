#!/bin/bash
#title          :section2.4.1_exp_extract.sh
#description    : .
#author         :Ruby(Yiru) Sheng
#usage          :source $CMRP_PATH/script/section2.4.1_exp_extract.sh ../annotation/RD_uniq_dna.lst  2>&1 | tee exp_extract.log
#input files    :(Required) 'RD_uniq_dna.lst' - a list of all unique orthologs isoforms
#output files   :renamed expression matrices of only clustered orthologous genes
#bash_version   :4.4.19(1)-release
#=======================================================================================================================

# at "$CMRP_PATH/sample/orthologs/expression_matrix/"

# copy 'RD_uniq_dna.lst' by the input path from its original location
list_path="$1"
cp -v ${list_path} .


for line in `ls -1 ./TPM_input/*.gene.TPM`; do
  file=`basename $line`
  sp_name=${file%.gene.TPM}
  per_set_lst=${sp_name}"_uniq_dna.lst"
  tpm_file=${sp_name}".gene.TPM"
  extracted_tpm=${sp_name}".allsp_clugene.TPM"

  grep ${sp_name} RD_uniq_dna.lst | sort | uniq > tmp_per_set.lst
  head -1 ${tpm_file} > tmp_exp.matrix

  while IFS= read -r line; do
    group_num=`echo $line | sed 's/_/|/; s/.*>\(.*\)|.*/\1/'`
    dataset_num=`echo $line |cut -d'_' -f3`
    pattern="${line%_i*}"
    pattern="${pattern#*_}"
    tpm_file=${dataset_num}".gene.TPM"
    cat ${tpm_file} | awk -v pat="$pattern" '{ if ($0 ~ pat) { print; } }' >> tmp_exp.matrix
  done < tmp_per_set.lst

  mv -v tmp_exp.matrix ${extracted_tpm}
  mv -v tmp_per_set.lst ${per_set_lst}
done

rm -v RD_uniq_dna.lst