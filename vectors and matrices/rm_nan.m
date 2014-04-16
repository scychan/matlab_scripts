function v = rm_nan(v)

v(isnan(v)) = [];