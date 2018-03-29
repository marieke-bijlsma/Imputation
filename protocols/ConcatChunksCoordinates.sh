#MOLGENIS walltime=05:59:59 mem=10gb ppn=1


#string intermediateDir
#string concatChunksCoordinatesFile
#list chr

declare -a chunksCoordinatesMerged

#Function to check if array contains value
array_contains () {
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array-}"; do
        if [[ "$element" == "$seeking" ]]; then
            in=0
            break
        fi
    done
    return $in
}


#Create string with chromosomes
#This check needs to be performed because Compute generates duplicate values in array
CHRS=()

for chromosome in "${chr[@]}"
do
	array_contains CHRS "${chromosome}" || CHRS+=("${chromosome}")    # If chr does not exist in array, add it
done


#Concat every chromosome into one file
printf "Copy liftover files to results directory "

for i in ${CHRS[@]}
do
	chunk="${intermediateDir}/chr${i}_chunks_coordinates"

        if [[ -f "${chunk}" ]]
        then
                chunksCoordinatesMerged[${i}]="${chunk}"

                echo "Processing: ${chunk}"

        else
                echo "${chunk} not found, proceeding..."
                continue
        fi
done

#Concatenate chunks coordinate files
cat "${chunksCoordinatesMerged[@]}" > "${concatChunksCoordinatesFile}"


#Add header line to file and replace tabs to commas
echo -e "\nAdding header line to file"

sed -i 's/\t/,/g' "${concatChunksCoordinatesFile}"
sed -i '1ichrom,fromChrPos,toChrPos' "${concatChunksCoordinatesFile}"


echo -e "\nConcatenating is finished, resulting merged chunk coordinate file can be found here: ${intermediateDir}\n"
