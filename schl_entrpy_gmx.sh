#!/bin/bash
# ================================================================
# Script: schl_entrpy_gmx.sh
# Purpose: Fits trajectory, computes covariance matrices, and 
#          then calculates Schlitter entropy in windows for a MD simulation
# Requirements: GROMACS installed and environment sourced
# ================================================================

# -------------------------------
# User parameters (change as needed)
# -------------------------------
tpr_file="dry.tpr"      # input topology file
traj_file="dry.xtc"     # input trajectory
fit_traj="dry_fit.xtc"  # output fitted trajectory
window=10000       # ps per window (10 ns)
step=5000          # ps between windows (5 ns)
tmax=1000000       # total simulation length in ps (1 µs)
temp=300           # simulation temperature (K)
index_group="Backbone"  # atom group for analysis

# -------------------------------
# Step 1: Fit trajectory to reference
# -------------------------------
echo "Fitting trajectory to reference structure..."
gmx trjconv -s $tpr_file -f $traj_file -o $fit_traj -fit rot+trans <<EOF
Protein
Protein
EOF
echo "Trajectory fitting complete: $fit_traj"

# -------------------------------
# Step 2: Loop over time windows
# -------------------------------
for start in $(seq 0 $step $((tmax-window))); do
    end=$((start + window))
    echo "Processing window: $start - $end ps"

    # Covariance analysis
    covar_out="eigenval_${start}_${end}.xvg"
    eigenvec_out="eigenvec_${start}_${end}.trr"
    avg_out="avg_${start}_${end}.pdb"

    echo "Computing covariance matrix..."
    gmx covar -s $tpr_file \
              -f $fit_traj \
              -b $start -e $end \
              -o $covar_out \
              -v $eigenvec_out \
              -av $avg_out <<EOF
$index_group
$index_group
EOF

    # Schlitter entropy calculation
    entropy_log="entropy_${start}_${end}.log"
    echo "Calculating Schlitter entropy..."
    gmx anaeig -v $eigenvec_out \
               -eig $covar_out \
               -entropy \
               -temp $temp \
               -nevskip 6 > $entropy_log

    echo "Window $start-$end ps complete: $entropy_log"
    echo "-------------------------------------------"
done

echo "All windows processed. Script finished."
