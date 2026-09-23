%RUN_KV43_ANALYSIS  Kv4.3 activation / inactivation / recovery and Ih analysis.
%
%   Put all HEKA .mat exports in one folder. File names: <cell>_<tag>.mat
%       a = Kv4.3 activation        i = steady-state inactivation
%       r = recovery from inact.    h = HCN (Ih) activation + tail
%   Then set dataDir below and run this script.
%
%   Output (in outDir):
%     activation_sweeps.csv    per sweep: V, peak, ss, amplitude (peak-ss),
%                              mono/bi-exponential decay tau, conductance
%     inactivation_sweeps.csv  per sweep: prepulse V, amplitude, taus, I/Imax
%     recovery_sweeps.csv      per sweep: dt, P1/P2 amplitudes, P2/P1
%     ih_sweeps.csv            per sweep: V, Ih amplitude, tau, tail current
%     cell_summary.csv         per cell: V1/2, k, Gmax, tau_rec, Ih max amp, ...
%     cell<N>_<protocol>.png   QC figures - check them!
%     kv43_results.mat         everything as MATLAB structs

cfg = kv43_default_config();
cfg.dataDir = pwd;                                % <-- folder with the .mat files
cfg.outDir  = fullfile(cfg.dataDir, 'kv43_results');

% Adjust to your solutions / protocols:
cfg.EK   = -90;               % mV, K+ reversal for the conductance calculation
cfg.ih.V = -40:-10:-120;      % mV, Ih step voltages (not stored in the _h files)

results = kv43_analyze_folder(cfg);
