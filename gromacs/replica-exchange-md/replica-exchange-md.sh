#!/bin/bash

start=$SECONDS

out_file="out"
gro_file="gro"
mdp_file="mdp"
top_file="top"

mdp_remd_file="remd"
out_remd_file="temp"

# read in remd temperatures (e.g.)
IFS=', ' read -r -a temperature_array <<< "300.00, 306.97, 314.06, 321.27, 328.61, 336.07, 343.65, 351.36, 359.20, 367.18, 375.28, 383.53, 391.91, 400.46, 409.13, 417.97, 425.00"

for n in $(seq 1 1 17);
do	

	# get current remperature and directory name
	temperature="${temperature_array[n-1]}"
	dirname="temp"${n}
	
	mkdir ${dirname}
	cd ${dirname}
	
	echo Calculation ${n} with temperature ${temperature}K
		
	cp ../$gro_file.gro .
	cp ../$mdp_file.mdp .
	cp ../$mdp_remd_file.mdp .
	cp ../$top_file.top .
	cp ../*.itp .
	
	# replace temperatures in both mdp files
	sed -i -e "s/TEMPERATURE/${temperature}/g" $mdp_file.mdp
	sed -i -e "s/TEMPERATURE/${temperature}/g" $mdp_remd_file.mdp
		
	# equilibration run
	gmx grompp -c $gro_file -f $mdp_file -p $top_file -o $out_file
	gmx mdrun -nt 16 -v -deffnm $out_file -pin on #-pme gpu -nb gpu

	# creation of remd temp.tpr file for remd
	gmx grompp -c $out_file.gro -f $mdp_remd_file -p $top_file -o $out_remd_file
	
	cd ..
done

# start remd
mpiexec -np 17 mdrun_mpi -multidir temp{1..17} -replex 1000 -deffnm temp -pin on

echo Timing: $((SECONDS - start)) seconds
