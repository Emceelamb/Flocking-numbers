function kv43_plot_steps(rec, fits, V, tlim, ttl, file, x, y, b, direction, ylab)
%KV43_PLOT_STEPS  QC figure: traces with peak/ss markers and exponential fits,
%   plus the normalized curve with its Boltzmann fit.
fig = figure('Visible', 'off', 'Position', [50 50 1100 420]);
subplot(1,2,1); hold on
tw = rec.t >= tlim(1) & rec.t <= tlim(2);
plot(rec.t(tw), rec.I(tw,:), 'Color', [0.65 0.65 0.65]);
pk = -Inf; lo = Inf;
for k = 1:numel(fits)
    m = fits(k);
    if isfinite(m.peak), plot(m.tOn + m.tPeak/1e3, m.peak, 'r.', 'MarkerSize', 12); end
    plot(tlim(2), m.ss, 'b.', 'MarkerSize', 10);
    if ~isempty(m.fitT)
        s = m.fitT <= tlim(2);
        plot(m.fitT(s), m.fitY(s), 'r-', 'LineWidth', 1);
        if ~isempty(m.fitY2), plot(m.fitT(s), m.fitY2(s), 'c--', 'LineWidth', 1); end
    end
    pk = max(pk, m.peak); lo = min(lo, m.ss);
end
ylim([min(lo, 0) - 0.1*abs(pk), pk * 1.15]);
xlim(tlim);
xlabel('Time (s)'); ylabel('I (pA)');
title([ttl ' (red: peak/mono-exp, cyan: bi-exp, blue: ss)']);
subplot(1,2,2); hold on
plot(x, y, 'ko', 'MarkerFaceColor', 'k');
if isfinite(b.V50)
    vv = linspace(min(x), max(x), 200);
    plot(vv, 1 ./ (1 + exp(direction*(b.V50 - vv)/b.k)), 'r-');
end
xlabel('V (mV)'); ylabel(ylab);
title(sprintf('V_{1/2} = %.1f mV, k = %.1f mV', b.V50, b.k));
kv43_save_fig(fig, file);
end
