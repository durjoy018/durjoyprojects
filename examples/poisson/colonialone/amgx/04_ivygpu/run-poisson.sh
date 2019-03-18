#!/usr/bin/env bash

#SBATCH --job-name="04amgx"
#SBATCH --output=log%j.out
#SBATCH --error=log%j.err
#SBATCH --partition=ivygpu
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=12
#SBATCH --time=00:30:00

nodes=4

module load gcc/4.9.2
module load openmpi/1.8/gcc/4.9.2
module load cuda/toolkit/8.0

AMGXWRAPPER_DIR="/groups/barbalab/software/amgxwrapper/1.4/linux-openmpi-opt"
export PATH="$AMGXWRAPPER_DIR/example/poisson/bin":$PATH

AMGX_DIR="/groups/barbalab/software/amgx/git/master/linux-openmpi-opt"
export LD_LIBRARY_PATH="$AMGX_DIR/lib":$LD_LIBRARY_PATH

export CUDA_VISIBLE_DEVICES=0,1

configdir="../config"
outdir="output"
mkdir -p $outdir

niters=5
counter=1

while [ $counter -le $niters ]
do
	casename="poisson_amgx_${nodes}nodes_run${counter}"
	mpiexec poisson \
		-caseName $casename \
		-mode AmgX_GPU \
		-cfgFileName $configdir/poisson_solver.info \
		-Nx 1000 -Ny 500 -Nz 50 \
		-log_view ascii:${outdir}/view_run${counter}.log \
		-options_left >> ${outdir}/stdout_run${counter}.txt 2> ${outdir}/stderr_run${counter}.txt
	((counter++))
done

exit 0
