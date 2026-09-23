function [rows, summ] = kv43_analyze_recovery(rec, cfg, cellId)
%KV43_ANALYZE_RECOVERY  Recovery from inactivation (<cell>_r), P1-dt-P2.
%   Amplitude (peak - ss) of P1 and P2; recovery = P2/P1; the recovery time
%   course is fitted with R(dt) = Rinf * (1 - exp(-dt/tau))  (R(0) = 0).
c   = cfg.rec;
nSw = size(rec.I, 2);
rows = [];
for k = 1:nSw
    % P2 onset: from voltage channel if present, else nominal intervals
    tP2 = c.gapStart + c.dtNominal(min(k, end));
    if ~isempty(rec.V)
        j = find(rec.t > c.gapStart + 1e-3 & rec.V(:,k) > c.VthP2, 1);
        if ~isempty(j), tP2 = rec.t(j); end
    end
    dt = tP2 - c.gapStart;
    m1 = kv43_measure_transient(rec.t, rec.I(:,k), c.tP1(1), c.tP1(2), cfg);
    m2 = kv43_measure_transient(rec.t, rec.I(:,k), tP2, tP2 + c.P2dur, cfg);
    r.cell      = cellId;
    r.protocol  = 'recovery';
    r.series    = rec.series;
    r.sweep     = rec.sweeps(k);
    r.dt_ms     = round(dt*1e4)/10;
    r.P1_peak_pA = m1.peak; r.P1_ss_pA = m1.ss; r.P1_amp_pA = m1.amp;
    r.P2_peak_pA = m2.peak; r.P2_ss_pA = m2.ss; r.P2_amp_pA = m2.amp;
    r.P1_tau_ms  = m1.tau;  r.P2_tau_ms = m2.tau;
    r.recovery   = m2.amp / m1.amp;
    r.flag       = strtrim(['P1:' m1.flag ' P2:' m2.flag]);
    rows = [rows; r]; %#ok<AGROW>
    P2(k) = m2; tP2s(k) = tP2; %#ok<AGROW>
end
dts = [rows.dt_ms]'; R = [rows.recovery]';
f = fit_recovery(dts, R);
summ.rec_tau_ms = f.tau;
summ.rec_Rinf   = f.Rinf;
summ.rec_fitR2  = f.r2;
summ.rec_first_dt_recovery = R(1);
if R(1) > 0.5
    warning('kv43:rec', ['Cell %s: already %.0f%% recovered at the shortest interval ' ...
        '(%.0f ms); tau_rec is poorly constrained - use shorter intervals.'], ...
        cellId, 100*R(1), dts(1));
end
summ.rec_P1amp_mean_pA = mean([rows.P1_amp_pA]);

if cfg.makePlots
    fig = figure('Visible', 'off', 'Position', [50 50 1100 420]);
    subplot(1,2,1); hold on
    tw = rec.t >= c.tP1(1) - 0.01 & rec.t <= max(tP2s) + 0.2;
    plot(rec.t(tw), rec.I(tw,:), 'Color', [0.6 0.6 0.6]);
    for k = 1:nSw
        plot(tP2s(k) + P2(k).tPeak/1e3, P2(k).peak, 'r.', 'MarkerSize', 12);
    end
    ylim([min(0, min([rows.P1_ss_pA])) - 200, max([rows.P1_peak_pA]) * 1.15]);
    xlabel('Time (s)'); ylabel('I (pA)'); title(sprintf('Cell %s - recovery', cellId));
    subplot(1,2,2); hold on
    plot(dts, R, 'ko', 'MarkerFaceColor', 'k');
    if isfinite(f.tau)
        tt = linspace(0, max(dts), 200)';
        plot(tt, f.Rinf*(1 - exp(-tt/f.tau)), 'r-');
    end
    xlabel('\Deltat (ms)'); ylabel('P2/P1');
    title(sprintf('\\tau_{rec} = %.1f ms', f.tau));
    kv43_save_fig(fig, fullfile(cfg.outDir, sprintf('cell%s_recovery.png', cellId)));
end
end

function f = fit_recovery(dt, R)
% R = Rinf*(1-exp(-dt/tau)); Rinf solved linearly, tau by grid + fminbnd
ok = isfinite(dt) & isfinite(R); dt = dt(ok); R = R(ok);
f = struct('tau', NaN, 'Rinf', NaN, 'r2', NaN);
if numel(dt) < 3, return; end
    function [e, A] = cost(lt)
        b = 1 - exp(-dt/exp(lt));
        A = b \ R;
        e = sum((R - A*b).^2);
    end
grid = linspace(log(0.1), log(10*max(dt)), 100);
e = arrayfun(@cost, grid);
[~, k] = min(e);
lt = fminbnd(@cost, grid(max(k-1,1)), grid(min(k+1,end)));
[e, A] = cost(lt);
f.tau = exp(lt); f.Rinf = A;
f.r2 = 1 - e / sum((R - mean(R)).^2);
end
