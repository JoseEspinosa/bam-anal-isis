#!/bin/bash

#Run Manta with default parameters. Needs input bam as parameter 1, and output directory as parameter 2
reference=~/genome_references/GRCh38.d1.vd1.fa
manta=~/soft/manta-1.4.0/bin/configManta.py
strelka=~/soft/Strelka2.8.4/bin/configureStrelkaSomaticWorkflow.py

#Color constants to print in different colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

#Check if the number of parameters is the expected and run Strelka if it is the case
if (( $# == 3 )); then
        sta=`date`
        SECONDS=0
        #Configurar el run de Manta. Se definen los parametros que tendra el futuro ejecutable. Este ejecutable se crea siempre automaticamente despues de ejecutar este script
        $manta --normalBam $1 --tumorBam $2 --referenceFasta $reference --exome --runDir $3
        if (( $? == 0 )); then
                echo -e "\n\n${GREEN}Manta configured successfully.${NC} Running the analysis\n\n"
                #Ejecutar el ejecutable de Manta. Este archivo se crea siempre alla donde se ha especificado en el parametro "runDir" (mirar arriba). Los parametros que necesita el ejecutable es saber si el programa se ejecuta en una maquina o en un cluster
                #El numero de procesos en los que se ejecutara Strelka y la verbosidad
                $3/runWorkflow.py -m local -j 8 --quiet
                if (( $? == 0 )); then
                        echo -e "${GREEN}Manta ran successfully.${NC} Results stored in $2"

                        end=`date`
                        echo -e "Manta started at $sta\nEnded at $end"
			#Configurar Strelka, de la misma manera que se ha hecho con Manta. Se incluye un parametro adicional con los candidatos a indels que ha encontrado Manta para que el comando sea mas
			#TODO change the output dir in case of somatic
                        $strelka --normalBam $1 --tumorBam $2 --referenceFasta $reference --exome --indelCandidates $3/results/variants/candidateSmallIndels.vcf.gz --runDir $3+Strelka2
                        if (( $? == 0 )); then
                                echo -e "${GREEN}Strelka-2 configured successfully.${NC} Running the analysis\n\n"
                                #Idem de la ejecucion de Manta
                                $3+Strelka2/runWorkflow.py -m local -j 8 --quiet
                                if (( $? == 0 )); then
                                        echo -e "${GREEN}Strelka-2 ran successfully.${NC} Results stored in $2+Strelka2"
                                        end=`date`
                                        echo -e "Script started at $sta\nEnded at $end"
                                        printf 'Elapsed time -> %dh:%dm:%ds\n' $(($SECONDS/3600)) $(($SECONDS%3600/60)) $(($SECONDS%60))
                                else
                                        echo -e >&2 "\n${RED}Execution aborted. Check below possible errors${NC}\n"
                                        exit 1
                                fi
                        else
                                echo -e >&2 "\n${RED}Execution aborted. Check below possible errors${NC}\n"
                                exit 1
                        fi
                fi
        else
                echo -e >&2 "\n${RED}Execution aborted. Check below possible errors${NC}\n"
                exit 1
        fi
else
        echo -e >&2 "\nUSAGE: runManta.sh input.bam output_directory\n" #Print the output using stderr
        exit 1
fi
