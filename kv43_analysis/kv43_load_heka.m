function rec = kv43_load_heka(file)
%KV43_LOAD_HEKA  Load a HEKA PatchMaster MATLAB export.
%   Variables are named Trace_<group>_<series>_<sweep>_<channel> and hold
%   [time(s) value] columns. Channel 1 = current (A), channel 2 = voltage (V).
%   Returns a struct array (one element per series) with fields
%     t (s, column), I (pA, samples x sweeps), V (mV, samples x sweeps or []),
%     series, sweeps.

S     = load(file);
names = fieldnames(S);
tok   = regexp(names, '^Trace_(\d+)_(\d+)_(\d+)_(\d+)$', 'tokens', 'once');
ok    = ~cellfun(@isempty, tok);
names = names(ok);
idx   = cellfun(@(c) reshape(str2double(c), 1, []), tok(ok), 'UniformOutput', false);
idx   = vertcat(idx{:});                 % [group series sweep channel]
if isempty(idx)
    error('kv43:load', 'No Trace_* variables found in %s', file);
end

seriesList = unique(idx(:,2))';
rec = struct('t', {}, 'I', {}, 'V', {}, 'series', {}, 'sweeps', {});
for s = seriesList
    inS    = idx(:,2) == s;
    sweeps = unique(idx(inS,3))';
    r.series = s;
    r.sweeps = sweeps;
    r.t = [];
    r.I = [];
    r.V = [];
    for k = 1:numel(sweeps)
        iI = find(inS & idx(:,3) == sweeps(k) & idx(:,4) == 1, 1);
        iV = find(inS & idx(:,3) == sweeps(k) & idx(:,4) == 2, 1);
        d = S.(names{iI});
        if isempty(r.t), r.t = d(:,1); end
        r.I(:,k) = d(:,2) * 1e12;
        if ~isempty(iV)
            d = S.(names{iV});
            r.V(:,k) = d(:,2) * 1e3;
        end
    end
    rec(end+1) = r; %#ok<AGROW>
end
end
