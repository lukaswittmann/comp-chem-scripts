#!/bin/bash

$ locale
LANG=it_IT.UTF-8

start=$SECONDS

out_file="put"
gro_file="gro"
mdp_file="mdp"
top_file="top"
ndx_file="ndx"


for calc in $(seq 1 1 10);
do
	mkdir ${calc}
	cd ${calc}
	echo step: ${calc}
	
	rm *.tpr
	
	cp ../$gro_file.gro .
	cp ../$mdp_file.mdp .
	cp ../$ndx_file.ndx .
	cp ../$top_file.top .
	cp ../*.itp .
		
	gmx grompp -c $gro_file -n $ndx_file -f $mdp_file -p $top_file -o $out_file
	gmx mdrun -nt 16 -v -deffnm $out_file #-pme gpu -nb gpu

	
	cd ..
	
	echo ${calc}/$out_file.xvg >> forcefiles.dat
	
done

./jarzynski.py -f forcefiles.dat -T 300 -v 0.006667 -rinit 1.40695

gracebat -nxy *.xvg -printfile jarzynski.eps

echo Gesamtdauer: $((SECONDS - start))
