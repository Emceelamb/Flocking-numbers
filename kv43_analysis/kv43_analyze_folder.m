function results = kv43_analyze_folder(cfg)
%KV43_ANALYZE_FOLDER  Analyse all <cell>_<tag>.mat files in cfg.dataDir.
%   Files from the same cell share the number (e.g. 1_a, 1_i, 1_r, 1_h).
%   Writes per-sweep CSVs per protocol, a per-cell summary CSV, a
%   results .mat and QC figures to cfg.outDir.
if nargin < 1, cfg = kv43_default_config(); end
if ~exist(cfg.outDir, 'dir'), mkdir(cfg.outDir); end

files = dir(fullfile(cfg.dataDir, '*.mat'));
tagKeys = fieldnames(cfg.tags);
list = struct('file', {}, 'cell', {}, 'tag', {});
for f = files'
    tok = regexp(f.name, '(\d+)_([A-Za-z])\.mat$', 'tokens', 'once');
    if isempty(tok) || ~ismember(lower(tok{2}), tagKeys), continue; end
    list(end+1) = struct('file', fullfile(f.folder, f.name), ...
                         'cell', tok{1}, 'tag', lower(tok{2})); %#ok<AGROW>
end
if isempty(list)
    error('kv43:nofiles', 'No <cell>_<a|i|r|h>.mat files found in %s', cfg.dataDir);
end
[~, o] = sort(cellfun(@str2double, {list.cell}));
list = list(o);

rowsBy  = struct('activation', {{}}, 'inactivation', {{}}, 'recovery', {{}}, 'ih', {{}});
summary = containers.Map();
results = struct();
for L = list
    proto = cfg.tags.(L.tag);
    fprintf('Cell %s  %-12s %s\n', L.cell, proto, L.file);
    recs = kv43_load_heka(L.file);
    for s = 1:numel(recs)
        switch proto
            case 'activation',   [rows, summ] = kv43_analyze_activation(recs(s), cfg, L.cell);
            case 'inactivation', [rows, summ] = kv43_analyze_inactivation(recs(s), cfg, L.cell);
            case 'recovery',     [rows, summ] = kv43_analyze_recovery(recs(s), cfg, L.cell);
            case 'ih',           [rows, summ] = kv43_analyze_ih(recs(s), cfg, L.cell);
        end
        for r = rows', rowsBy.(proto){end+1} = r; end
        % per-cell summary (first series of each protocol; later ones suffixed)
        if isKey(summary, L.cell), cs = summary(L.cell); else, cs = struct('cell', L.cell); end
        fn = fieldnames(summ);
        for j = 1:numel(fn)
            key = fn{j};
            if s > 1, key = sprintf('%s_s%d', key, recs(s).series); end
            cs.(key) = summ.(fn{j});
        end
        summary(L.cell) = cs;
        results.(['cell' L.cell]).(proto)(s).rows    = rows;
        results.(['cell' L.cell]).(proto)(s).summary = summ;
    end
end

protos = fieldnames(rowsBy);
for p = 1:numel(protos)
    kv43_write_csv(fullfile(cfg.outDir, [protos{p} '_sweeps.csv']), rowsBy.(protos{p}));
end
kv43_write_csv(fullfile(cfg.outDir, 'cell_summary.csv'), values(summary));
save(fullfile(cfg.outDir, 'kv43_results.mat'), 'results', 'cfg');
fprintf('Results written to %s\n', cfg.outDir);
end
