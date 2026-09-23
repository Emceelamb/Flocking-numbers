function [rows, summ] = kv43_analyze_ih(rec, cfg, cellId)
%KV43_ANALYZE_IH  HCN / Ih activation + tail currents (<cell>_h).
%   Hyperpolarizing step (cfg.ih.tOn-tOff) followed by a common tail step.
%   Per sweep:
%     I_inst  : "instantaneous" current (mean over cfg.ih.instWin after onset)
%     I_ss    : steady-state current (mean of last cfg.ih.ssWin of the step)
%     ih_amp  : Ih amplitude = I_inst - I_ss (pA, positive = inward Ih)
%     tau     : single-exponential activation time constant (ms)
%     tail    : instantaneous tail current; tail_amp relative to the least
%               activated sweep; normalized tail -> activation curve (Boltzmann)
c   = cfg.ih;
nSw = size(rec.I, 2);
V   = c.V(:);
if numel(V) < nSw
    warning('kv43:ih', 'cfg.ih.V has %d voltages but cell %s has %d sweeps; padding with NaN.', ...
        numel(V), cellId, nSw);
    V(end+1:nSw) = NaN;
end
fs  = 1 / median(diff(rec.t));
win = @(a, b) rec.t >= a & rec.t < b;
rows = [];
for k = 1:nSw
    I = rec.I(:,k);
    iInst = mean(I(win(c.tOn + c.instWin(1), c.tOn + c.instWin(2))));
    iSS   = mean(I(win(c.tOff - c.ssWin, c.tOff)));
    iTail = mean(I(win(c.tOff + c.instWin(1), c.tOff + c.instWin(2))));
    r.cell       = cellId;
    r.protocol   = 'ih';
    r.series     = rec.series;
    r.sweep      = rec.sweeps(k);
    r.V_mV       = V(k);
    r.I_hold_pA  = mean(I(win(c.tOn - 0.1, c.tOn - 0.005)));
    r.I_inst_pA  = iInst;
    r.I_ss_pA    = iSS;
    r.ih_amp_pA  = iInst - iSS;
    r.tau_ms     = NaN;
    r.tau_R2     = NaN;
    if c.fitTau && r.ih_amp_pA > cfg.kv.minAmp
        sel = win(c.tOn + c.instWin(1), c.tOff);
        f = kv43_fit_exp(rec.t(sel), I(sel), 1);
        r.tau_ms = f.tau * 1e3; r.tau_R2 = f.r2;
    end
    r.I_tail_pA  = iTail;
    rows = [rows; r]; %#ok<AGROW>
end
tail = [rows.I_tail_pA]';
tailAmp = max(tail) - tail;                 % inward tail relative to least activated sweep
b = kv43_fit_boltzmann(V, tailAmp, -1);
for k = 1:nSw
    rows(k).tail_amp_pA = tailAmp(k);
    rows(k).tail_norm   = tailAmp(k) / b.Ymax;
end
summ.ih_maxAmp_pA      = max([rows.ih_amp_pA]);
[~, iMax] = max(abs(V));
summ.ih_tau_at_mostNeg_ms = rows(iMax).tau_ms;
summ.ih_V50_mV         = b.V50;
summ.ih_k_mV           = b.k;
summ.ih_tailMax_pA     = b.Ymax;
summ.ih_fitR2          = b.r2;

if cfg.makePlots
    fig = figure('Visible', 'off', 'Position', [50 50 1100 420]);
    subplot(1,2,1); hold on
    tw = win(c.tOn - 0.1, c.tailOff + 0.1);
    plot(rec.t(tw), rec.I(tw,:), 'Color', [0.6 0.6 0.6]);
    plot(repmat(c.tOn + mean(c.instWin), 1, nSw), [rows.I_inst_pA], 'b.', 'MarkerSize', 12);
    plot(repmat(c.tOff - c.ssWin/2, 1, nSw), [rows.I_ss_pA], 'r.', 'MarkerSize', 12);
    plot(repmat(c.tOff + mean(c.instWin), 1, nSw), tail, 'm.', 'MarkerSize', 12);
    lo = min([[rows.I_ss_pA] tail']); hi = max([rows.I_hold_pA]);
    ylim([lo - 0.2*abs(lo), hi + 0.2*abs(lo) + 50]);
    xlabel('Time (s)'); ylabel('I (pA)');
    title(sprintf('Cell %s - Ih (blue inst, red ss, magenta tail)', cellId));
    subplot(1,2,2); hold on
    plot(V, tailAmp / b.Ymax, 'ko', 'MarkerFaceColor', 'k');
    vv = linspace(min(V), max(V), 200);
    plot(vv, 1 ./ (1 + exp((vv - b.V50)/b.k)), 'r-');
    xlabel('V_{step} (mV)'); ylabel('Tail I/I_{max}');
    title(sprintf('V_{1/2} = %.1f mV, k = %.1f mV', b.V50, b.k));
    kv43_save_fig(fig, fullfile(cfg.outDir, sprintf('cell%s_ih.png', cellId)));
end
end
