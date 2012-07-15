function converted = convert_rondo_params(params)

converted = cell(size(params));

for i = 1:length(params)
    converted{i} = eval(params{i});
end