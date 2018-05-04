#!/bin/bash

rm results # remove results
if [ -e map_pipe ]; then # if map_pipe exists, remove
	rm map_pipe*
fi
if [ -e reduce_pipe ]; then # if reduce_pipe exists, remove
	rm rduce_pipe*
fi

# Count number of text files for mapping
txtCount=$( ls ~/alan/Projects/MapReduce/salesFigs-full | wc -1)
echo "Number of files: " $textCount

# if pipes do not exist create them
if [ ! -p map_pipe ]; then
	mkfifo map_pipe
fi

if [ ! -p reduce_pipe ]; then
	mkfifo reduce_pipe
fi

# Invoke Map function passing text file arguements
for file in ~/alan/Projects/MapReduce/salesFigs-full/*; do
	./map.sh $file &
done

# create listening loop until received required Map finsihed messages, pass unique keys to keys file
mapCount=0
touch keys
while [ $mapCount -lt $txtCount ]; do
	read input < map_pipe
	if [ "$input" = "MAP FINISHED" ]; then
		((mapCount++))
		countinue
	fi
	grep -q $input keys || echo $input >> keys
done

# remove map pipe once finished
rm -rf map_pipe

# invoke reduce function on unique key files, listen until finished, echo input to results file, remove key file
keyfiles='cat keys'
for line in $keyfiles; do 
	./reduce.sh $line &
	read input < reduce_pipe
	echo "$line: $input" >> results
	rm $line
done

# sort results and echo them to screen
sort results
echo $results

rm -rf reduce_pipe # remove reduce pipe
rm keys # remove keys file

