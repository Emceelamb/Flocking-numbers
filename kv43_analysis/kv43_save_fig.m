function kv43_save_fig(fig, file)
%KV43_SAVE_FIG  Save a figure as PNG and close it (MATLAB and Octave).
set(fig, 'PaperPositionMode', 'auto');
print(fig, file, '-dpng', '-r110');
close(fig);
end
