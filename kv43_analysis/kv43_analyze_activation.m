function [rows, summ] = kv43_analyze_activation(rec, cfg, cellId)
%KV43_ANALYZE_ACTIVATION  Kv4.3 activation (<cell>_a): one test step per sweep.
%   Per sweep: test voltage, peak, steady state, amplitude (peak - ss),
%   decay taus, conductance G = amp/(V - EK). Per cell: Boltzmann fit of
%   G/Gmax vs V.
c   = cfg.act;
nSw = size(rec.I, 2);
V   = kv43_step_voltage(rec, c.tOn, c.tOff, c.Vnominal);
rows = [];
for k = 1:nSw
    m = kv43_measure_transient(rec.t, rec.I(:,k), c.tOn, c.tOff, cfg);
    r = kv43_row(cellId, 'activation', rec, k, V(k), m);
    r.G_nS = m.amp / (V(k) - cfg.EK) * 1e-3;     % pA/mV = nS * 1e3
    rows = [rows; r]; %#ok<AGROW>
    fits(k) = m; %#ok<AGROW>
end
G = [rows.G_nS]';
b = kv43_fit_boltzmann(V, G, 1);
for k = 1:nSw, rows(k).G_norm = G(k) / b.Ymax; end

summ.act_V50_mV  = b.V50;
summ.act_k_mV    = b.k;
summ.act_Gmax_nS = b.Ymax;
summ.act_fitR2   = b.r2;
[summ.act_maxAmp_pA, iMax] = max([rows.amp_pA]);
summ.act_tau_at_maxAmp_ms  = rows(iMax).tau_ms;
summ.act_V_at_maxAmp_mV    = rows(iMax).V_mV;

if cfg.makePlots
    kv43_plot_steps(rec, fits, V, [c.tOn-0.01 c.tOn+0.35], ...
        sprintf('Cell %s - activation', cellId), ...
        fullfile(cfg.outDir, sprintf('cell%s_activation.png', cellId)), ...
        V, G/b.Ymax, b, 1, 'G/G_{max}');
end
end
