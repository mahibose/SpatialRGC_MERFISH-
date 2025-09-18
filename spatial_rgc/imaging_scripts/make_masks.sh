#!/bin/bash -l
#SBATCH --job-name=MAKE_MASKS
#SBATCH --account=co_kslab
#SBATCH --partition=savio3_gpu
#SBATCH --qos=savio_lowprio
# Wall clock limit:
#SBATCH --time=24:00:00
#SBATCH --output=MAKE_MASKS_%j.out
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --error=MAKE_MASKS_%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=kushalnimkar@berkeley.edu
#SBATCH --export=ALL
module load anaconda3
conda activate spatial_rgc
#UPDATE THIS FILE PATH IF NECESSARY
python spatial_rgc/imaging_scripts/parallel_stitch.py --zlayers 0 1 2 3 4 5 6 7 --channel Cellbound2 --trial_name $2 --downsample_ratio 4 --diameter 21.72 --flow_threshold 0.4 --cellprob_threshold 0.0 --num_processes 1 --resegment --merge --use_gpu --model_name $2  --subdirectory $1 $3
