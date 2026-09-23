function r = kv43_row(cellId, protocol, rec, k, V, m)
%KV43_ROW  One results row for a Kv4.3 step measurement.
r.cell      = cellId;
r.protocol  = protocol;
r.series    = rec.series;
r.sweep     = rec.sweeps(k);
r.V_mV      = V;
r.peak_pA   = m.peak;
r.ss_pA     = m.ss;
r.amp_pA    = m.amp;
r.tPeak_ms  = m.tPeak;
r.tau_ms    = m.tau;
r.tau_R2    = m.tauR2;
r.tauFast_ms = m.tauF;
r.tauSlow_ms = m.tauS;
r.tauWeighted_ms = m.tauW;
r.fracFast  = m.fracF;
r.biexp_R2  = m.tau2R2;
r.flag      = m.flag;
end
