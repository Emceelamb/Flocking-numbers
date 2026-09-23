function r = kv43_measure_transient(t, I, tOn, tOff, cfg)
%KV43_MEASURE_TRANSIENT  Peak, steady state, amplitude and decay tau of an
%   outward A-type (Kv4.3) current evoked by a step from tOn to tOff.
%     amp  = peak - steady state (steady state = mean of last cfg.kv.ssWin)
%     tau  = mono-exponential decay tau fitted from the peak (ms)
%     tauF/tauS/tauW = double-exponential fast/slow/weighted taus (ms)
%   The peak search skips the capacitive transient (cfg.kv.blank) and any
%   samples clipped at the ADC limit (plus cfg.kv.satPad).

kv = cfg.kv;
fs = 1 / median(diff(t));
i0 = find(t >= tOn, 1);
i1 = find(t < tOff, 1, 'last');
y  = I(i0:i1);
ts = t(i0:i1) - tOn;

% --- blanking of capacitive transient / saturation
sat     = abs(y) >= cfg.adcLimit & ts < kv.satSearch;
lastSat = find(sat, 1, 'last');
iStart  = round(kv.blank*fs) + 1;
if ~isempty(lastSat)
    iStart = max(iStart, lastSat + round(kv.satPad*fs));
end
iEnd = min(numel(y), round(kv.peakWin*fs));

% --- peak & steady state
ysm = movmean(y, max(1, round(kv.smooth*fs)));
[pk, k] = max(ysm(iStart:iEnd));
k  = k + iStart - 1;
nSS = round(kv.ssWin*fs);
ss = mean(y(end-nSS+1:end));

r.tOn       = tOn;
r.peak      = pk;
r.ss        = ss;
r.amp       = pk - ss;
r.tPeak     = ts(k) * 1e3;                    % ms after step onset
r.saturated = ~isempty(lastSat);
r.clipped   = pk >= cfg.clipWarn;
r.tBlank    = ts(iStart) * 1e3;               % ms blanked
flags = {};
if k == iEnd || r.amp < 0
    % current still rising at the end of the peak window (or peak below
    % steady state): there is no transient (A-type) component
    flags{end+1} = 'no_transient';
    r.peak = NaN; r.amp = 0; r.tPeak = NaN;
elseif k == iStart
    flags{end+1} = 'peak_at_blank_edge';     % may be capacitive artefact
end
if r.saturated, flags{end+1} = 'cap_transient_saturated'; end
if r.clipped,   flags{end+1} = 'PEAK_CLIPPED'; end
r.flag = strjoin(flags, ' ');

% --- decay fit
r.tau = NaN; r.tauR2 = NaN; r.tauF = NaN; r.tauS = NaN; r.tauW = NaN;
r.fracF = NaN; r.tau2R2 = NaN;
r.fitT = []; r.fitY = []; r.fitY2 = [];
if r.amp >= kv.minAmp
    % if the peak is clipped, start the fit once the current leaves the clip
    kFit = k;
    if r.clipped
        c = find(y(k:iEnd) >= cfg.clipWarn, 1, 'last');
        kFit = k + c;
    end
    j1 = min(numel(y), kFit + round(kv.fitDur*fs));
    tf = ts(kFit:j1);
    yf = y(kFit:j1);
    f1 = kv43_fit_exp(tf, yf, 1);
    r.tau   = f1.tau * 1e3;
    r.tauR2 = f1.r2;
    tt = tf - tf(1);
    r.fitT = tf + tOn;
    r.fitY = f1.A*exp(-tt/f1.tau) + f1.C;
    if kv.fitBiexp
        f2 = kv43_fit_exp(tf, yf, 2);
    end
    if kv.fitBiexp && f2.ok
        r.tauF   = f2.tau(1) * 1e3;
        r.tauS   = f2.tau(2) * 1e3;
        r.tauW   = f2.tauW * 1e3;
        r.fracF  = abs(f2.A(1)) / sum(abs(f2.A));
        r.tau2R2 = f2.r2;
        r.fitY2  = f2.A(1)*exp(-tt/f2.tau(1)) + f2.A(2)*exp(-tt/f2.tau(2)) + f2.C;
    end
end
end
