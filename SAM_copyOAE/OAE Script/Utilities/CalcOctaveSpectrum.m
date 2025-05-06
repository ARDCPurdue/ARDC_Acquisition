function oct_avg_output = CalcOctaveSpectrum(input, idxs_lo)
% function oct_avg_output = CalcOctaveBands(input, idxs_lo)
%
% This function will calculate the (fractional) octave bands of the input 
% signal, based on the input indexing.
% Input:
%   input
%     input spectrum to be averaged
%   idxs_lo
%     index vector containing the lowest spectrum bin/index for every 
%     octave band
% Output:
%   oct_avg_output
%     octave band spectrum averaged from the input spectrum

input = input(:);
oct_avg_output = zeros(length(idxs_lo),1);
for x = 1:(length(idxs_lo)-1)
    oct_avg_output(x) = mean(input(idxs_lo(x):(idxs_lo(x+1)-1)),1);
end
oct_avg_output(end) = mean(input(idxs_lo(end):end),1);
end
