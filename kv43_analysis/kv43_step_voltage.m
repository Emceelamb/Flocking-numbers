function V = kv43_step_voltage(rec, t0, t1, Vnominal)
%KV43_STEP_VOLTAGE  Median recorded voltage (mV) in [t0 t1] for each sweep;
%   falls back to the nominal values when no voltage channel was exported.
nSw = size(rec.I, 2);
if isempty(rec.V)
    V = Vnominal(:);
    if numel(V) < nSw, V(end+1:nSw) = NaN; end
    V = V(1:nSw);
    return
end
sel = rec.t >= t0 + 5e-3 & rec.t < t1 - 5e-3;
V = round(median(rec.V(sel,:), 1)' * 10) / 10;
end
