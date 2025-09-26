#!/bin/bash
# ================================================================
# Script: schl_entrpy_cumulative.sh
# Purpose: Fit trajectory, compute covariance matrices, and calculate
#          cumulative Schlitter entropy for an MD simulation
#
# Notes:
#   - Requires GROMACS installed and environment sourced
#   - Calculates entropy cumulatively (0 → n×window ps)
#   - Outputs eigenvalues, eigenvectors, average structures, and log files
# ================================================================

# -------------------------------
# User parameters (edit as needed)
# -------------------------------
tpr_file="system.tpr"         # input topology file
traj_file="trajectory.xtc"    # input trajectory
fit_traj="trajectory_fit.xtc" # output fitted trajectory
window=10000                  # ps per window (e.g., 10 ns)
tmax=1000000                  # total simulation length in ps (e.g., 1 µs)
temp=300                      # simulation temperature (K)
index_group="Backbone"        # atom group for analysis (e.g., Backbone, Protein, C-alpha)

# -------------------------------
# Step 1: Fit trajectory to reference
# -------------------------------
echo "================================================"
echo " STEP 1: Fitting trajectory to reference structure"
echo " Input trajectory : $traj_file"
echo " Output trajectory: $fit_traj"
echo "================================================"
gmx trjconv -s $tpr_file -f $traj_file -o $fit_traj -fit rot+trans <<EOF
Protein
Protein
EOF
echo "[✔] Trajectory fitting complete: $fit_traj"
echo

# -------------------------------
# Step 2: Loop over cumulative windows
# -------------------------------
echo "================================================"
echo " STEP 2: Cumulative Schlitter entropy calculation"
echo " Window size : $window ps"
echo " Total time  : $tmax ps"
echo " Temperature : $temp K"
echo " Group used  : $index_group"
echo "================================================"
echo

for end in $(seq $window $window $tmax); do
  start=0
  echo ">>> Processing cumulative window: $start - $end ps"

  # Define output file names
  covar_out="eigenval_${start}_${end}.xvg"
  eigenvec_out="eigenvec_${start}_${end}.trr"
  avg_out="avg_${start}_${end}.pdb"
  entropy_log="entropy_${start}_${end}.log"

  # Compute covariance matrix
  echo "    [1/2] Running covariance analysis..."
  gmx covar -s $tpr_file -f $fit_traj -b $start -e $end \
            -o $covar_out -v $eigenvec_out -av $avg_out <<EOF
$index_group
$index_group
EOF

  # Compute Schlitter entropy
  echo "    [2/2] Calculating Schlitter entropy..."
  gmx anaeig -v $eigenvec_out -eig $covar_out \
             -entropy -temp $temp -nevskip 6 > $entropy_log

  echo ">>> Completed window: $start - $end ps → Results in $entropy_log"
  echo "---------------------------------------------------------------"
done

echo
echo "================================================"
echo " All cumulative Schlitter entropy calculations complete."
echo " Results: entropy_0_<end>.log for each cumulative window."
echo "================================================"
