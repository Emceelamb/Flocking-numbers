function cfg = kv43_default_config()
%KV43_DEFAULT_CONFIG  Protocol timings and analysis settings.
%   All times are in seconds, voltages in mV, currents in pA.
%   Defaults match the HEKA exports <cell>_a/_i/_r/_h.mat (20 kHz, 10 s sweeps).
%   Edit here (or override fields in run_kv43_analysis.m) if a protocol changes.

% ---- files -------------------------------------------------------------
cfg.dataDir   = pwd;              % folder containing the .mat files
cfg.outDir    = fullfile(pwd, 'kv43_results');
cfg.tags      = struct('a', 'activation', 'i', 'inactivation', ...
                       'r', 'recovery',   'h', 'ih');
cfg.makePlots = true;

% ---- general -----------------------------------------------------------
cfg.adcLimit  = 5100;   % |I| >= this (pA) is treated as amplifier/ADC saturation
cfg.clipWarn  = 4950;   % peaks >= this (pA) are flagged as (probably) clipped:
                        % the amplifier range at this gain ends at ~ +/-5 nA
cfg.EK        = -90;    % K+ reversal potential for conductance (set to your solutions!)

% ---- Kv4.3 transient measurement (shared by a / i / r) ---------------
cfg.kv.blank     = 2.0e-3;  % ignore first 2 ms after step (capacitive transient)
cfg.kv.satPad    = 0.5e-3;  % extra blanking after the last saturated sample
cfg.kv.satSearch = 30e-3;   % look for saturation within the first 30 ms
cfg.kv.smooth    = 0.5e-3;  % moving-average width used to find the peak
cfg.kv.peakWin   = 50e-3;   % peak searched within 50 ms of step onset
cfg.kv.ssWin     = 20e-3;   % steady state = mean of the last 20 ms of the step
cfg.kv.fitDur    = 0.5;     % decay fitted from peak to peak + fitDur (or step end)
cfg.kv.minAmp    = 50;      % no tau is fitted if peak-ss amplitude < minAmp (pA)
cfg.kv.fitBiexp  = true;    % also fit a double exponential

% ---- activation (<cell>_a) ---------------------------------------------
cfg.act.tOn      = 3.0;              % test step onset
cfg.act.tOff     = 5.0;              % test step end
cfg.act.Vnominal = -60:5:-15;        % used only if no voltage channel

% ---- steady-state inactivation (<cell>_i) --------------------------------
cfg.inact.tPre     = [2.0 3.0];      % conditioning prepulse
cfg.inact.tOn      = 3.0;            % test pulse (-20 mV) onset
cfg.inact.tOff     = 4.0;
cfg.inact.Vnominal = -120:10:-30;    % used only if no voltage channel

% ---- recovery from inactivation (<cell>_r) -------------------------------
cfg.rec.tP1       = [2.5 3.0];       % P1 (inactivating) pulse
cfg.rec.gapStart  = 3.0;             % start of recovery interval
cfg.rec.P2dur     = 0.5;             % P2 duration
cfg.rec.dtNominal = (10:50:360)*1e-3; % recovery intervals, used if no V channel
cfg.rec.VthP2     = -60;             % P2 onset detected as V crossing this level

% ---- HCN / Ih (<cell>_h) -------------------------------------------------
% NOTE: the _h exports contain no voltage channel, so step voltages must be
% given here. Check them against your PatchMaster protocol!
cfg.ih.V        = -40:-10:-120;      % hyperpolarizing step per sweep (ASSUMED)
cfg.ih.tOn      = 2.0;               % activation step onset
cfg.ih.tOff     = 4.0;               % activation step end (= tail onset)
cfg.ih.tailOff  = 5.0;               % end of tail step
cfg.ih.instWin  = [8 12]*1e-3;       % "instantaneous" current window after a step
cfg.ih.ssWin    = 50e-3;             % steady state = mean of last 50 ms of step
cfg.ih.fitTau   = true;              % fit single exponential to Ih activation
end
