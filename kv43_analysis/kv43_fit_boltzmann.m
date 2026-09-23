function b = kv43_fit_boltzmann(V, y, direction)
%KV43_FIT_BOLTZMANN  Fit y = Ymax ./ (1 + exp((V50 - V)/k))   direction =  1
%                   or y = Ymax ./ (1 + exp((V - V50)/k))   direction = -1
%   (k > 0 in both cases). Ymax is solved linearly; V50 and k by fminsearch.
V = V(:); y = y(:);
ok = isfinite(V) & isfinite(y);
V = V(ok); y = y(ok);
b = struct('V50', NaN, 'k', NaN, 'Ymax', NaN, 'r2', NaN);
if numel(V) < 4, return; end

model = @(x, V) 1 ./ (1 + exp(direction*(x(1) - V)/x(2)));
    function [e, A] = cost(x)
        if x(2) <= 0.1, e = Inf; A = NaN; return; end
        g = model(x, V);
        A = g \ y;
        e = sum((y - A*g).^2);
    end
% start: V50 near the half-max point, k = 8 mV
[~, i] = min(abs(y - (max(y)+min(y))/2));
opt = optimset('Display', 'off', 'MaxFunEvals', 4000, 'MaxIter', 4000);
best = Inf;
for k0 = [3 8 15]
    x = fminsearch(@cost, [V(i) k0], opt);
    e = cost(x);
    if e < best, best = e; xb = x; end
end
[e, A] = cost(xb);
b.V50 = xb(1); b.k = xb(2); b.Ymax = A;
b.r2  = 1 - e / sum((y - mean(y)).^2);
end
