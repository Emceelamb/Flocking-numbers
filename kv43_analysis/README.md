# Kv4.3 / Ih analysis (MATLAB)

Analyses HEKA PatchMaster MATLAB exports named `<cell>_<tag>.mat`
(same number = same cell):

| tag | protocol | measured |
|-----|----------|----------|
| `a` | Kv4.3 activation (−80 mV prepulse, test steps −60…−15 mV, 3–5 s) | peak, steady state, **amplitude = peak − ss**, **decay τ** (mono- and, where resolvable, bi-exponential), G = amp/(V−E_K), Boltzmann V½/k |
| `i` | steady-state inactivation (1 s prepulse −120…−30 mV, test −20 mV at 3 s) | same per test pulse, I/Imax, Boltzmann V½/k |
| `r` | recovery (P1 −20 mV, Δt at −97.5 mV, P2 −20 mV) | P1/P2 amplitudes, P2/P1, τ_rec |
| `h` | Ih activation (2–4 s) + tail (4–5 s) | **Ih amplitude = I_inst − I_ss** (positive = inward), activation τ, tail currents → activation curve |

## Usage

Needs only base MATLAB (no toolboxes); also runs in GNU Octave.

```matlab
addpath('path/to/kv43_analysis')
% edit dataDir / EK / ih.V in run_kv43_analysis.m, then:
run_kv43_analysis
```

All timings and settings are in `kv43_default_config.m`.

Output goes to `<dataDir>/kv43_results/`: one CSV per protocol (one row per
sweep), `cell_summary.csv` (one row per cell), `kv43_results.mat`, and QC
figures `cell<N>_<protocol>.png`. Check the figures.

## Things to check

* **Ih voltages are not stored in the `_h` files** (no voltage channel).
  They default to −40:−10:−120 mV, which is an assumption. Set `cfg.ih.V`
  to your protocol.
* **E_K** (`cfg.EK`, default −90 mV) is only used for the conductance.
* **Clipping.** The amplifier range ends at about ±5 nA. Peaks ≥ 4950 pA are
  flagged `PEAK_CLIPPED`, and those amplitudes are underestimates. In cell 1
  this affects the inactivation test pulses after strong prepulses and all
  recovery P1/P2 peaks. P2/P1 ratios are less affected because both peaks
  clip. Consider a lower amplifier gain.
* `peak_at_blank_edge` means the "peak" is at the end of the 2 ms blanking
  window, so it is probably capacitive artefact (small currents near
  threshold). `no_transient` means no transient peak was found, so the
  amplitude is set to 0.
* Recovery: cell 1 is already ~70 % recovered at the shortest interval
  (10 ms), so τ_rec is poorly constrained. Add shorter intervals.
