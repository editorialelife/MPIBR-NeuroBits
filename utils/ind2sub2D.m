function [r, c] = ind2sub2D(siz, idx)
% faster ind2sub2D
% siz(1) = nrows
% siz(2) = ncols

    r = rem(idx-1, siz(1)) + 1;
    c = (idx - r) / siz(1) + 1;
end

