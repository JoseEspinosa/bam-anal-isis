#!/usr/bin/env bash

source ~/anaconda2/etc/profile.d/conda.sh

bedtools=bedtools	

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

if (( $# == 1 ))
then
	conda activate base
	SECONDS=0
	sta=`date`
	$bedtools genomecov -bg -ibam $1 > bamCoverage.tsv
	if (( $? == 0 ))
	then
		echo -e "${GREEN}genomeCoverage ran successfully.${NC}\n"
	else 
		echo -e >&2 "\n${RED}Execution aborted. Check below possible errors${NC}\n"
		conda deactivate
		exit 1
	fi
	end=`date`
	echo -e "bedtools genomecov started at $sta\nEnded at $end"
	printf 'Elapsed time -> %dh:%dm:%ds\n' $(($SECONDS/3600)) $(($SECONDS%3600/60)) $(($SECONDS%60))
	conda deactivate
else
	echo -e >&2 "\nUSAGE: runGenomeCov.sh input.bam\n" #Print the output using stderr
	exit 1
fi