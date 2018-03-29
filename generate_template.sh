#!/bin/bash

module load Molgenis-Compute/v16.11.1-Java-1.8.0_74
module load Imputation/1.0.0
module list

HOST=$(hostname -s)
environmentParameters="parameters_${HOST}"

PROJECT=$(awk 'NR==2 {print $1}' FS=',' datasheet.csv)
RAWDATA=$(awk 'NR==2 {print $2}' FS=',' datasheet.csv)
RUNID=$(awk 'NR==2 {print $5}' FS=',' datasheet.csv)
PIPELINE=$(awk 'NR==2 {print $6}' FS=',' datasheet.csv)

TMPDIRECTORY=$(basename $(cd ../../ && pwd ))

GROUP=$(basename $(cd ../../../ && pwd ))
groupParameters="parameters_${GROUP}"

HOMEDIR=/groups/${GROUP}/${TMPDIRECTORY}/
WORKDIR=${HOMEDIR}/generatedscripts/${PROJECT}/
INTERMEDIATEDIR=${HOMEDIR}/tmp/${PROJECT}/
RUNDIR=${HOMEDIR}/projects/${PROJECT}/${RUNID}/jobs/


echo "$WORKDIR AND $RUNNUMBER"

if [ -f .compute.properties ];
then
     rm .compute.properties
fi

mkdir -p ${INTERMEDIATEDIR}

if [ -f ${WORKDIR}/${parameters}_converted.csv  ];
then
        rm -rf ${WORKDIR}/${parameters}_converted.csv
fi

if [ -f ${WORKDIR}/group_parameters_converted.csv  ];
then
	rm -rf ${WORKDIR}/group_parameters_converted.csv
fi

if [ -f ${WORKDIR}/environment_parameters_converted.csv  ];
then
        rm -rf ${WORKDIR}/environment_parameters_converted.csv
fi

if [[ ${PIPELINE} == "phasing" ]]
then
	workflow="workflow_phasing.csv"
        parameters="parameters_phasing"
	chunks=""

elif [[ ${PIPELINE} == "imputation" ]]
then
	workflow="workflow_imputation.csv"
        parameters="parameters_imputation"
	chunks="-p ${RAWDATA}/chunks_coordinates_concatenated.csv"
else
	echo "No pipeline is chosen..."
fi


perl ${EBROOTIMPUTATION}/convertParametersGitToMolgenis.pl ${EBROOTIMPUTATION}/${parameters}.csv > \
${WORKDIR}/${parameters}_converted.csv

perl ${EBROOTIMPUTATION}/convertParametersGitToMolgenis.pl ${EBROOTIMPUTATION}/${environmentParameters}.csv > \
${WORKDIR}/environment_parameters_converted.csv

perl ${EBROOTIMPUTATION}/convertParametersGitToMolgenis.pl ${EBROOTIMPUTATION}/${groupParameters}.csv > \
${WORKDIR}/group_parameters_converted.csv


sh ${EBROOTMOLGENISMINCOMPUTE}/molgenis_compute.sh \
-p ${WORKDIR}/${parameters}_converted.csv \
-p ${WORKDIR}/environment_parameters_converted.csv \
-p ${WORKDIR}/group_parameters_converted.csv \
-p ${WORKDIR}/datasheet.csv \
-p ${EBROOTIMPUTATION}/chromosomes.csv \
${chunks} \
-w ${EBROOTIMPUTATION}/${workflow} \
-rundir ${RUNDIR} \
-b slurm \
--weave \
--generate
