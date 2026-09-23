function f = kv43_fit_exp(t, y, nExp)
%KV43_FIT_EXP  Fit y = sum_k A_k*exp(-t/tau_k) + C  (nExp = 1 or 2).
%   Uses variable projection: amplitudes and offset are solved linearly
%   for each candidate tau, so only the tau(s) are searched (coarse grid
%   followed by fminbnd / fminsearch). Needs no toolboxes.
%   t must start at (about) 0. Returns taus in the units of t.

f = struct('tau', NaN, 'A', NaN, 'C', NaN, 'r2', NaN, 'tauW', NaN, 'ok', false);
if numel(t) < 3*nExp + 1 || numel(t) ~= numel(y), return; end
t = t(:) - t(1);
y = y(:);
% decimate long records to <= ~5000 points by block averaging (speed)
n = numel(t);
b = max(1, floor(n/5000));
if b > 1
    m = floor(n/b)*b;
    t = mean(reshape(t(1:m), b, []), 1)';
    y = mean(reshape(y(1:m), b, []), 1)';
end

dt   = max(median(diff(t)), eps);
lo   = log(max(dt, 1e-5));
hi   = log(max(t(end)*3, 10*dt));
sse0 = sum((y - mean(y)).^2);

f = struct('tau', NaN, 'A', NaN, 'C', NaN, 'r2', NaN, 'tauW', NaN, 'ok', false);
if numel(t) < 3*nExp + 1, return; end

if nExp == 1
    g   = linspace(lo, hi, 80);
    e   = arrayfun(@(lt) sse1(lt, t, y), g);
    [~, k] = min(e);
    lt  = fminbnd(@(lt) sse1(lt, t, y), g(max(k-1,1)), g(min(k+1,end)));
    f.ok = k > 1 && k < numel(g);          % minimum not at the search bound
    [e, p] = sse1(lt, t, y);
    f.tau = exp(lt); f.A = p(1); f.C = p(2);
    f.tauW = f.tau;
else
    g = linspace(lo, hi, 30);
    best = Inf; x0 = [g(1) g(2)];
    for i = 1:numel(g)
        for j = i+1:numel(g)
            e = sse2([g(i) g(j)], t, y, lo, hi);
            if e < best, best = e; x0 = [g(i) g(j)]; end
        end
    end
    opt = optimset('Display', 'off', 'TolX', 1e-6, 'TolFun', 1e-9);
    x   = fminsearch(@(x) sse2(x, t, y, lo, hi), x0, opt);
    x   = sort(x);
    [e, p] = sse2(x, t, y, lo, hi);
    if ~isfinite(e), return; end
    f.tau = exp(x); f.A = p(1:2)'; f.C = p(3);
    f.tauW = sum(abs(f.A).*f.tau) / sum(abs(f.A));   % amplitude-weighted tau
    % a double exponential is only meaningful if the two components are
    % distinct, have the same sign and each carries >= 5% of the amplitude
    frac = abs(f.A) / sum(abs(f.A));
    f.ok = f.tau(2)/f.tau(1) > 1.5 && all(frac > 0.05) && prod(sign(f.A)) > 0 ...
        && all(x > lo + 0.05) && all(x < hi - 0.05);     % not stuck at a bound
end
f.r2 = 1 - e/sse0;
end

function [e, p] = sse1(lt, t, y)
X = [exp(-t/exp(lt)) ones(size(t))];
p = X \ y;
e = sum((y - X*p).^2);
end

function [e, p] = sse2(x, t, y, lo, hi)
p = [NaN; NaN; NaN];
if abs(x(1)-x(2)) < 1e-3 || any(x < lo) || any(x > hi), e = Inf; return; end
X = [exp(-t/exp(x(1))) exp(-t/exp(x(2))) ones(size(t))];
p = X \ y;
e = sum((y - X*p).^2);
end
