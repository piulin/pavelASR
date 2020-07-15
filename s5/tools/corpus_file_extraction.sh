#!/bin/sh


text="text/4.tsv"
video=video/4_project.mp4

videoname=$(basename $video)

SAVEIFS=$IFS   # Save current IFS
IFS=$'\n'      # Change IFS to new line

text=($(cut -f3 $text))

IFS=$SAVEIFS   # Restore IFS

for ((i=0;i<${#text[@]};++i))
do	
	echo "${videoname%.*}-$i ${text[i]^^}"
done




