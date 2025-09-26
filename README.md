# gmxTRPY
Calculate Schlitter's Entropy with GROMACS

Unlock the hidden motion of your proteins! 
This bash script takes your molecular dynamics trajectory, fits it to a reference structure, and slices it into customizable time windows to compute covariance matrices and Schlitter entropies. 
Perfect for analyzing temperature-dependent protein flexibility and dynamics over long simulations—fast, automated, and ready to handle microsecond-scale trajectories.

💡 Features:

- Fit trajectories to remove rotational/translational motion
- Slice simulations into customizable windows for detailed analysis
- Compute covariance matrices and Schlitter entropy per window
- Overlapping or non-overlapping window support
- Clean, time-stamped output ready for plotting




💡 Outputs will be generated per time window:

- `eigenval_START_END.xvg` – eigenvalues
- `eigenvec_START_END.trr` – eigenvectors
- `avg_START_END.pdb` – average structure
- `entropy_START_END.log` – Schlitter entropy


