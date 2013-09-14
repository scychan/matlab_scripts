function output = concatcellcontents(cellarray,h_or_v)
% function output = concatcellcontents(cellarray,[h_or_v])

if ~exist('h_or_v','var')
    output = [cellarray{:}];
else
    switch h_or_v
        case 'h'
            output = [];
            for i = 1:numel(cellarray)
                output = [output cellarray{i}];
            end
        case 'v'
            output = [];
            for i = 1:numel(cellarray)
                output = [output; cellarray{i}];
            end
    end
end