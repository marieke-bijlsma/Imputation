#MOLGENIS walltime=04:59:59 mem=5gb ppn=2

#string outputPerChr
#string intermediateDir
#string chr
#string shapeItVersion
#string stage
#string bglChunksVersion
#string rawdata


#Create tmp/tmp to save unfinished results
makeTmpDir "${outputPerChr}"
tmpOutputPerChr="${MC_tmpFile}"


#load modules and list currently loaded modules
${stage} "${shapeItVersion}"
${stage} "${bglChunksVersion}"
module list


#Convert and compress haps file (sample file also needed)
#use rawdata column in datasheet for input files location
shapeit -convert \
        --input-haps "${intermediateDir}/chr${chr}.gh" \
	--output-log "${tmpOutputPerChr}_convert.log" \
        --output-vcf "${tmpOutputPerChr}_haps_converted.vcf.gz"


#Create chunks
makeBGLCHUNKS --vcf "${tmpOutputPerChr}_haps_converted.vcf.gz" --window 500 --overlap 0 --output "${tmpOutputPerChr}_chunks_coordinates"


echo -e "\nmv ${tmpOutputPerChr}_{haps_converted.vcf.gz,convert.log,chunks_coordinates} ${intermediateDir}"
mv "${tmpOutputPerChr}"_{haps_converted.vcf.gz,convert.log,chunks_coordinates} "${intermediateDir}"

echo -e "\nCreating chunks is finished, resulting chunk coordinates can be found here: ${intermediateDir}\n"
