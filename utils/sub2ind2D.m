function [idx] = sub2ind2D(siz, rows, cols)
% a fast replacement for sub2ind in 2D

idx = rows + (cols - 1) * siz(1);

end

