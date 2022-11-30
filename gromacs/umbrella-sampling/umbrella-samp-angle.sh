#!/bin/bash

start=$SECONDS

out_file="out"
gro_file="gro"
mdp_file="mdp"
top_file="top"
ndx_file="ndx"


for INIT_ANGLE in 0 10 20 30 40 50 60 70 80 90 100 110 120 130 140 150 160 170 180 190 200 210 220 230 240 250 260 270 280 290 300 310 320 330 340 350
do
	mkdir ${INIT_ANGLE}
	cd ${INIT_ANGLE}
	echo step: ${INIT_ANGLE}
	
	rm *.tpr
	
	cp ../$gro_file.gro .
	cp ../$mdp_file.mdp .
	cp ../$ndx_file.ndx .
	cp ../$top_file.top .
	cp ../*.itp .
	
	sed -i -e "s/INIT_ANGLE/$((${INIT_ANGLE}-180))/g" umbrella_dihedral.mdp
	

	
	gmx grompp -c $gro_file -n $ndx_file -f $mdp_file -p $top_file -o $out_file
	gmx mdrun -nt 8 -v -deffnm $out_file -pme gpu -nb gpu

	
	cd ..
	
done




for INIT_ANGLE in 0 10 20 30 40 50 60 70 80 90 100 110 120 130 140 150 160 170 180 190 200 210 220 230 240 250 260 270 280 290 300 310 320 330 340 350
do

echo ${INIT_ANGLE}/umbrella_dihedral_calc.xvg >> dihfiles.dat
echo ${INIT_ANGLE}/umbrella_dihedral_calc.tpr >> tprfiles.dat
	
done


gmx wham -ix dihfiles.dat -it tprfiles.dat -cycl -min -180 -max 180 -bins 1000 -temp 300 -b 10


gracebat -nxy histo.xvg -printfile histo.eps
gracebat -nxy profile.xvg -printfile profile.eps

echo Gesamtdauer: $((SECONDS - start))
