# Code for "Molecular and spatial analysis of ganglion cells on retinal flatmounts identifies perivascular neurons resilient to glaucoma"

## Table of Contents
1. [Project Overview](#project-overview)
2. [Repository Structure](#repository-structure)
3. [Getting Started](#getting-started)
4. [Usage](#usage)
5. [Cite](#cite)

## Project Overview
This repository contains analyses for the paper "Molecular and spatial analysis of ganglion cells on retinal flatmounts identifies perivascular neurons resilient to glaucoma" (Neuron)

The paper can be accessed here: 

https://www.cell.com/neuron/fulltext/S0896-6273(25)00552-5

## Repository Structure
- **spatial_rgc/notebook_scripts/**:
    - **train_models.ipynb** Trains cell type classifiers on reference scRNA-seq datasets
    - **preprocess_data.ipynb**: Preprocesses raw cell by gene matrices
    - **mosaic_analysis.ipynb**: Runs mosaic analysis and creates associated figure (post revision: Figure S5)
    - **make_figures.ipynb**: Creates all spatial transcriptomics figures aside from the mosaic analysis (post revision: Figure S5).
    - ***SOHU_stats.ipynb**: Creates all statistical calculations used for SOHU (Figure 5I, S6H, S6F'-K')
- **spatial_rgc/utils/**: Contains many util scripts used by the notebooks
- **spatial_rgc/models/**: Contains models used for cell type classification
- **spatial_rgc/imaging_scripts/**: Scripts related to segmentation. Sample data for one retina is [here](https://ucsf.box.com/s/2x0kd9pwnvgy5fh8h18s3gc6fgm3d7n0)
    - **images/**: Raw image files. Create one subdirectory for each tissue section (e.g. 140g_rn3_rg0 is Retina 3, tissue section 0)
    - **mappings/**: Coordinate mapping for mapping coordinates in cell by gene matrices to image files (micron_to_mosaic_transform.csv) AND transcripts information (detected_transcripts.csv).  One subdirectory for each tissue section.
    - **trials.sh** Run this to execute segmentation pipeline
    - **make_masks.sh**, **run_pipeline.sh** and **stitch_and_assign.sh**: Executes segmentation, stitching/transcripts, and adding antibody stains
    - **merge_masks.py, parallel_cell_matrix.py** and **add_costains.py** Segments cells,Assigns transcripts to cells, and adds antibody stains, respectively
    - **outputs/**: [Needs to be created manually] Output of segmentation pipeline
    - **assign.sh** (DEPRECATED) file that does max-z projection segmentation rather than stitching; not used in pipeline
- **spatial_rgc/figures/**: [Needs to be created manually] Figures are saved to here
    - **Figure_1**: Files for Figure 1
    - ... etc
- **spatial_rgc/data/**: [Needs to be created manually] Data for each retina tissue section to use in single-cell pipeline. Move all h5ad files from image segmentation pipeline into their own subdirectory (e.g. data/140g_rn3_rg0)
- **spatial_rgc/intermediate_figures/**: [Needs to be created manually]Intermediate figures from the cell by gene processing pipeline will be saved here

## Getting Started

1. See "installation.md" to clone this repository and install dependencies. Then read "spatial_rgc/file_structure.md" and ensure raw data is populated properly.
2. (Skip if not interested in recreating cell by gene matrix from raw images) Run **spatial_rgc/imaging_scripts/trials.sh**
3. Run through all analysis in **spatial_rgc/notebook_scripts/** in the order listed in Repository Structure to generate the figures

##  (UPDATED September 2025) Running the segmentation pipeline
1. NOTE: For testing, you can run take the raw MERFISH data (images, micron_to_mosaic_mapping.csv, detected_transcripts.csv) in Retina 3 in [here](https://ucsf.app.box.com/s/2x0kd9pwnvgy5fh8h18s3gc6fgm3d7n0/folder/338704542508). The intermediate and final outputs for Retina 3, region 0 are also [here](https://ucsf.box.com/s/7g1jo5byvhw61hlewbsnu9fzujry5005) in case you want to check.

2. The segmentation pipeline for each retina is a line in “trials.sh”. For testing, comment out all lines except the first line, so only 140g_rn3, which is Retina 3, runs. Run the command “bash trials.sh” and simply type in “0” (without quotes) when prompted and hit enter. For many regions you can type in “0 1 2 3” to segment regions 0 through 3.

3. The first step (make_masks.sh) will call merge_masks.py. This will expect image files of format “mosaic_Cellbound2_z{Z_ID}.tif” in the folder spatial_rgc/imaging_scripts/data/140g_rn{RUN_ID}_rg{REGION_ID} for all run and region ids you specified in the previous step. This will by default (4x4) downsample the original image files and do segmentation on each optical section. **Output**: This gives you segmentation masks for each optical section separately (c2knl_full_retina_mosaic_Cellbound2_z0…) and a file that combines these all into one 3D matrix (masks_combined_c2knl_full_retina.npy).

4. The second step will call stitch_and_assign.sh. This runs parallel_stitch.py which stitches the individual z-sections in masks_combined.npy **Output**: stitched_masks_c2knl_full_retina_comb.npy

5. Finally, parallel_cell_matrix.py assigns transcripts to various cells in the stitched segmentation and creates an anndata object, as well as a transcripts file with the downsampled coordinates added. It needs spatial_rgc/imaging_scripts/mappings/140g_rn{RUN_ID}_rg{REGION_ID}/detected_transcripts.csv and spatial_rgc/imaging_scripts/mappings/140g_rn{RUN_ID}_rg{REGION_ID}/micron_to_mosaic_pixel_transform.csv to be present. **Output**: Cellpose_model_c2knl_full_retina.h5ad, transcripts_mapped_c2knl_full_retina.csv

6.	(Optional) add_costain.py will update the .h5ad object with average channel intensity for other image channels if uncommented out in stitch_and_assign.sh
**Updates** Cellpose_model_c2knl_full_retina.h5ad

## (UPDATED September 2025) System requirements:
1.	The segmentation (merge_masks.py) requires a GPU with ~32-64 GB of RAM. This is because the whole image is segmented at once in this pipeline.
2.	The stitching and transcript assignment (parallel_stitch.py, parallel_cell_matrix.py) utilize multiprocessing on a high memory node. Reduce the “-num-processes” argument from 32 if you have fewer cores available.

## (UPDATED September 2025) General comments:
1.	File paths might need to be updated for your local system. E.g. these are capitalized in the variables in the python files in imaging_scripts or absolute paths in the bash script.
2.	If not using SLURM, replace the “sbatch…” commands in the pipeline, remove the “module load python” commands, and call the bash scripts individually. 
3.	Make sure the Cellpose version is the one in the requirements.txt (Cellpose2, NOT Cellpose3).


## Usage
Due to the size of the files, the data directory is empty by default. For running through analyses that only require the cell by gene matrix, see Zenodo. If more raw data is required than the sample provided, please email [Nicole Tsai](mailto:Nicole.Tsai@ucsf.edu), [Kushal Nimkar](mailto:kushalnimkar@berkeley.edu), [Karthik Shekhar](mailto:kshekhar@berkeley.edu),or [Xin Duan](mailto:Xin.Duan@ucsf.edu).

## Cite
If you find our code, analysis, or results useful and use them in your publications, please cite the paper at the following link: 
https://www.cell.com/neuron/fulltext/S0896-6273(25)00552-5 
