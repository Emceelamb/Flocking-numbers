function [rows, summ] = kv43_analyze_inactivation(rec, cfg, cellId)
%KV43_ANALYZE_INACTIVATION  Steady-state inactivation (<cell>_i).
%   Conditioning prepulse (varies per sweep) followed by a fixed test pulse.
%   Per sweep: prepulse voltage, test-pulse peak/ss/amplitude/taus.
%   Per cell: Boltzmann fit of I/Imax vs prepulse voltage.
c   = cfg.inact;
nSw = size(rec.I, 2);
V   = kv43_step_voltage(rec, c.tPre(1), c.tPre(2), c.Vnominal);
rows = [];
for k = 1:nSw
    m = kv43_measure_transient(rec.t, rec.I(:,k), c.tOn, c.tOff, cfg);
    r = kv43_row(cellId, 'inactivation', rec, k, V(k), m);
    rows = [rows; r]; %#ok<AGROW>
    fits(k) = m; %#ok<AGROW>
end
A = max([rows.amp_pA]', 0);
b = kv43_fit_boltzmann(V, A, -1);
for k = 1:nSw, rows(k).I_norm = A(k) / b.Ymax; end

summ.inact_V50_mV  = b.V50;
summ.inact_k_mV    = b.k;
summ.inact_Imax_pA = b.Ymax;
summ.inact_fitR2   = b.r2;
[summ.inact_maxAmp_pA, iMax] = max([rows.amp_pA]);
summ.inact_tau_at_maxAmp_ms  = rows(iMax).tau_ms;

if cfg.makePlots
    kv43_plot_steps(rec, fits, V, [c.tOn-0.01 c.tOn+0.35], ...
        sprintf('Cell %s - inactivation', cellId), ...
        fullfile(cfg.outDir, sprintf('cell%s_inactivation.png', cellId)), ...
        V, A/b.Ymax, b, -1, 'I/I_{max}');
end
end
