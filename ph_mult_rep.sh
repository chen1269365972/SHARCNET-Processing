#!/bin/sh

#SBATCH --time=1-00:00
#SBATCH --mem=10000M
#SBATCH --account=def-ibruce
#SBATCH --mail-user=wirtzfmr@mcmaster.ca
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=REQUEUE
#SBATCH --mail-type=ALL

module load nix
octave ph_mult_rep.m

# See "dos2unix" to remove extraneous Windows carriage return symbols.

# Author:  Michael R. Wirtzfeld ( michael.wirtzfeld [at] gmail.com )
# Creation Date:  Friday, July 22, 2012
# Modification Date:  Friday, July 25, 2014
#
# Sun Grid Engine (SGE) Options:  ("qsub" command-line options)
#
#$ -S /bin/sh
#
# matlab -nodisplay -nodesktop < ph_mult_rep.m
#
# To submit a job to the ECE Sun GRID Engine:
#   qsub -cwd -t 1:5:1 -v START="1",STEP="1",END="350" -hard -l is=AMD64 ph_mult_rep.sh
#
# To examine the job queue:
#   qstat (or "qstat | grep <username>" if a large number of jobs are active or queued)
#
# To kill an active job:
#   qdel <job-id>
#
# Reference(s):
# http://gridscheduler.sourceforge.net/htmlman/htmlman1/qsub.html


