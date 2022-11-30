#!/bin/bash

$ locale
LANG=it_IT.UTF-8

start=$SECONDS

out_file="out"
gro_file="gro"
mdp_file="mdp"
top_file="top"
ndx_file="ndx"


for INIT_COORD in $(seq start step end);
do
	mkdir ${INIT_COORD}
	cd ${INIT_COORD}
	echo step: ${INIT_COORD}
	
	rm *.tpr
	
	cp ../$gro_file.gro .
	cp ../$mdp_file.mdp .
	cp ../$ndx_file.ndx .
	cp ../$top_file.top .
	cp ../*.itp .
	
	sed -i -e "s/INIT_COORD/${INIT_COORD}/g" $mdp_file.mdp
	

	
	gmx grompp -c $gro_file -n $ndx_file -f $mdp_file -p $top_file -o $out_file
	gmx mdrun -nt 32 -v -deffnm $out_file #-pme gpu -nb gpu

	
	cd ..
	
  # example
	echo ${INIT_COORD}/$out_file.xvg >> pulldistfiles.dat
	echo ${INIT_COORD}/$out_file.tpr >> tprfiles.dat
	
done

# example
gmx wham -it tprfiles.dat -ix pulldistfiles.dat -o profile -hist histograms -bins 1000 -b 10

# example
gracebat -nxy histograms.xvg -printfile histograms.eps
gracebat -nxy profile.xvg -printfile profile.eps

echo Gesamtdauer: $((SECONDS - start))
