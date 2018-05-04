#!/bin/bash

while read -r line; do  # read file by line
	Binput=$( echo "$line" | cut -d "," -f8 )  # strip info from line by delimiter
	input="$( echo -e "${Binput}" | tr -d '[:space:]' )"

	if [ ! -f $input ]; then  # if file does not exist

		touch $input  # create file
		./P.sh $input  # lock file
		echo "$input: 1" >> "$input"  # write to file
		./V.sh $input  # unlock file
		./P.sh map_pipe  # lock pipe
		echo "$input"> map_pipe  # write to pipe
		./V.sh map_pipe  # unlock pipe
	else
		./P.sh $input  # lock file
		echo "$input: 1" >> "$input"  # write to file
		./V.sh $input  # unlock file
		./P.sh map_pipe  # lock pipe
		echo "$input" > map_pipe
		./V.sh map_pipe  # unlock pipe
	fi
done<$1
# ./P.sh map_pipe 
echo "MAP FINISHED" > map_pipe  # echo map finished to JobMaster on map_pipe
# ./V.sh map_pipe 
