function [f_center, freq_idx_lo] = CalcOctaveIndicesFreqs( freqs, points_per_octave )
% [f_center, freq_idx_lo] = GetOctaveIndicesFreqs( freqs, points_per_octave )
% 
% This function spits out the (fractional) octave center frequencies and 
% associated lowest index to the given frequency vector, to utilize an 
% indexing for later octave averaging.
% Input:   
%   freqs 
%     frequency vector containing frequency range and resolution
%   points_per_octave 
%     number of points desired for every octave band. 
% output:  
%   f_center 
%     vector containing center frequencies in the resolution set by number 
%     of 'points_per_octave' and the range specified in 'freqs'. 
%     NOTE: if an octave band contains no frequency bins it will be omitted
%   freq_idx_lo
%     vector of same size as 'f_center', containing the the lowest index 
%     in the 'freqs' vector required for calculating the octave band in the
%     corresponding 'f_center' frequency.
%     to calculate the octave band one should average bins until the next 
%     index in the this vector             

% set reference frequency to 125 Hz (could be any of the 11 standard
% frequencies
ref_freq = 125;

% find lowest fractional octave band
flowest = ref_freq*2^(round(points_per_octave*log2(freqs(1)/125))/points_per_octave);

% calculate all fractional octave bands
N_octaves = floor(log2(freqs(end)/flowest));
N_freqs = N_octaves*points_per_octave + 1;
f_center_all = flowest*2.^((0:(N_freqs-1))./points_per_octave);
f_thres_hi = flowest*2.^(((0:N_freqs)+0.5)./points_per_octave);

% find freqs closest to a fractional octave band
for x=1:length(freqs)
    [~,closest_oct_bin(x)] = min(abs(f_center_all - freqs(x)));
    % the 'min' function works linearly between center frequencies.
    % adjust index if frequency is above fractional octave band threshold
    if gt( freqs(x), f_thres_hi(closest_oct_bin(x)) ) && lt(closest_oct_bin(x), N_freqs)
        closest_oct_bin(x) = closest_oct_bin(x) + 1;
    end
end

% allocate zero vectors
freq_idx_lo = zeros(1,N_octaves);
f_center = zeros(1,N_octaves);

% find lowest index and center frequency for freq bin (if any)
for x=length(freqs):-1:1
    freq_idx_lo(closest_oct_bin(x)) = x;
    f_center(closest_oct_bin(x)) = f_center_all(closest_oct_bin(x));
end

% remove center frequencies and indices not set
freq_idx_lo = nonzeros(freq_idx_lo);
f_center = nonzeros(f_center);

end