#!/bin/bash

echo "Task 1:"
grep -v '^$' t2-input-example.txt | sort -t '|' -k1,1 | awk -F '|' '{print "\t"$2}' | grep -v '^$'


echo "Task 2:"
grep -v '^$' t2-input-example.txt | awk -F '|' '{print "\t"$2}' | grep -v '^$' | sort


echo "Task 3:"
fff=""
grep -v '^$' t2-input-example.txt | awk -F '|' '{print $3"|"$2}' | sort -t '|' -k1,1 -k2,2r | awk -F '|' '{
if ( fff!=$1 ){
	fff=$1;
	print "\t"$1":";
	print "\t\t"$2;
}else{
	print "\t\t"$2;
}
}'






echo "Task 4:"
grep -v '^$' t2-input-example.txt | sort -t '|' -k4,4n | awk -F '|' '{print "\t"$2}'


echo "Task 5:"
grep -v '^$' t2-input-example.txt | awk -F '|' '{print $2}' | awk '{print $NF, "\t"$0}' | sort | cut -f2- -d' '
