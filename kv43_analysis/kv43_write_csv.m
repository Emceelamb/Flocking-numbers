function kv43_write_csv(file, S)
%KV43_WRITE_CSV  Write a struct array (scalar numeric / char fields) to CSV.
%   Works without the table class so it also runs in Octave.
if isempty(S), return; end
% union of field names, keep first-seen order
names = {};
for i = 1:numel(S)
    fn = fieldnames(S{i});
    names = [names; fn(~ismember(fn, names))]; %#ok<AGROW>
end
fid = fopen(file, 'w');
fprintf(fid, '%s\n', strjoin(names', ','));
for i = 1:numel(S)
    vals = cell(1, numel(names));
    for j = 1:numel(names)
        if ~isfield(S{i}, names{j}), vals{j} = ''; continue; end
        v = S{i}.(names{j});
        if ischar(v)
            vals{j} = ['"' strrep(v, '"', '""') '"'];
        elseif isempty(v) || (isnumeric(v) && isnan(v))
            vals{j} = 'NaN';
        else
            vals{j} = sprintf('%.6g', v);
        end
    end
    fprintf(fid, '%s\n', strjoin(vals, ','));
end
fclose(fid);
end
