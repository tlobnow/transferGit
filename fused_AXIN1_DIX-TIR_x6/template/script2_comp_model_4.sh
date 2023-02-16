#!/bin/bash -l
#SBATCH -J 4_AF2C
#SBATCH --constraint="gpu"

# We will use 3 GPUs:
#SBATCH --gres=gpu:a100:3
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=54
#SBATCH --mem=375000

# When using >1 GPUs, please adapt the variable XLA_PYTHON_CLIENT_MEM_FRACTION as well (see below)!
#SBATCH --mail-type=NONE
#SBATCH --mail-user=$USER@mpiib-berlin.mpg.de
#SBATCH --time=24:00:00

set -e

### LOAD MODULES #############################################################
module load anaconda/3/2021.11
module load cuda/11.4
module load nvidia-dali/gpu-cuda-11.4/

### LIBRARY & AI AVAILABILITY ################################################
export LD_LIBRARY_PATH=/mpcdf/soft/SLE_15/packages/x86_64/alphafold/2.2.0/lib:/mpcdf/soft/SLE_15/packages/x86_64/cuda/11.4.2/lib64

# put temporary files into a ramdisk
export TMPDIR=${JOB_SHMTMPDIR}

### ENABLE CUDA UNIFIED MEMORY ###############################################
export TF_FORCE_UNIFIED_MEMORY=1
	# Enable jax allocation tweak to allow for larger models, note that
	# with unified memory the fraction can be larger than 1.0 (=100% of single GPU memory):
	# https://jax.readthedocs.io/en/latest/gpu_memory_allocation.html
	# When using 3 GPUs:
export XLA_PYTHON_CLIENT_MEM_FRACTION=9.0
		
	# run threaded tools with the correct number of threads (MPCDF customization)
export NUM_THREADS=${SLURM_CPUS_PER_TASK}
export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}

### TARGETS & LOCATIONS #######################################################
source 00_user_parameters.inc
source 02_user_parameters.inc
	# file name
	# data directory (where are params stored)
	# target list location
	# feature directory location
	# output directory
	# model_names
	# preset
	# model_preset
	# recycling setting
	# msa pairing

# GIVE ECHOS #################################################################
echo "Info: input file name is $FILE"
echo "Info: input target list is $TARGET_LST_FILE"
echo "Info: input feature directory is $FEA_DIR"
echo "Info: result output directory is $OUT_DIR"
echo "Info: model preset is $MODEL_PRESET"
echo "Info: msa pairing is $MSA_PAIRING"
echo "Info: recycling setting is $RECYCLING_SETTING"

# AF2Complex source code directory ###########################################

srun $PYTHON_PATH/python3 -u $AF_DIR/run_af2c_mod.py \
  --target_lst_path=$TARGET_LST_FILE \
  --data_dir=$DATA_DIR \
  --output_dir=$OUT_DIR \
  --feature_dir=$FEA_DIR \
  --model_names=model_4_multimer_v2 \
  --preset=$PRESET \
  --model_preset=$MODEL_PRESET \
  --save_recycled=$RECYCLING_SETTING \
  --msa_pairing=$MSA_PAIRING \
#  --checkpoint_tag=$CHECKPOINT_TAG

