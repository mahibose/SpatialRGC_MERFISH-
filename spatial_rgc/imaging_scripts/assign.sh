#THIS FILE DOES NOT GET CALLED NORMALLY; Kept here in case you want to run the maximum z projection segmentation

#!/bin/bash -l
#SBATCH --job-name=PARALLEL_ASSIGN
#SBATCH --account=co_kslab
#SBATCH --partition=savio3_bigmem
#SBATCH --qos=kslab_bigmem3_normal
# Wall clock limit:
#SBATCH --time=24:00:00
#SBATCH --output=PARALLEL_ASSIGN_%j.out
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=32
#SBATCH --error=PARALLEL_ASSIGN_%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=kushalnimkar@berkeley.edu
#SBATCH --export=ALL
module load python
source activate spatial_rgc
~/.conda/envs/RGC/bin/python /clusterfs/kslab/SPATIAL_RGC/org_runs/parallel_cell_matrix.py --downsample_ratio 4 --trial_name $2 --num_processes 32 --subdirectory $1 $3
