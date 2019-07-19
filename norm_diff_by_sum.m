function [out] = norm_diff_by_sum(v1, v2)

out = (v1-v2) ./ (v1+v2);

end