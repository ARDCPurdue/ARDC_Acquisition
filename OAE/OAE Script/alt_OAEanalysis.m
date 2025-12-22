function output = alt_OAEanalysis(oae_data, plot_yes)

if nargin < 2
    plot_yes = 1;
end

f1 = oae_data.f1;
f2 = oae_data.f2;
f1_rec_dB = oae_data.f1_rec_dB;
f2_rec_dB = oae_data.f2_rec_dB;
DP = oae_data.DP;
noisefloor_dp =oae_data.noisefloor_dp;
mean_response = oae_data.mean_response;
fs = oae_data.fs;
alltrials = oae_data.raw_responses;

dp_freq = 2*f1-f2;
N_signal = numel(mean_response(:,1));
w = dpss(N_signal, 1,1)';
w = w'/sum(w);
N_signal2 = 2.^nextpow2(N_signal);

%freq vector for the fft
f_out = fs*(0:(N_signal2/2))/N_signal2;

f_123 = [f1', f2', dp_freq']';
load TransducerCalIOWA.mat

mic_sens = ppval(pp.micSens,f_123); %mV/Pa
ref = 20e-6; %reference value of p0 in Pa

% stuff for recreating stimuli
dur = .5;
stimulusLength = round(fs*dur);
T=1/fs; % Sampling period
t = (0:stimulusLength-1)*T;        % Time vector
% Pad by extra 10% of duration (which is T)
pad = zeros(ceil(fs * 0.1 * T), 1);
rampdur = 0.020;
ramp = hanning(ceil(fs * rampdur));

% Loop over each frequency
numOfF2s = numel(f2);

for whichf = 1:numOfF2s

    noiseresponse = squeeze(alltrials(:,:,whichf));
    noiseresponse(:,2:2:end) = -1*noiseresponse(:,2:2:end);
    avgnoise = mean(noiseresponse,2,"omitnan");

    % get the fft of the mean_response
    fft_out(whichf, 1:N_signal2) = fft(w.*mean_response(:,whichf), N_signal2);

    % get the fft of the noise_response
    fft_noise(whichf, 1:N_signal2) = fft(w.*avgnoise, N_signal2);

    % just plot
    hf_fft1 = fft_out(whichf,1:numel(f_out));
    hf_fft = hf_fft1./(ppval(pp.micSens, f_out).*ref);
    out = 20.*log10(abs(hf_fft));

    ns_fft1 = fft_noise(1:numel(f_out));
    hf_ns = ns_fft1./(ppval(pp.micSens,f_out).*ref);
    out_ns = 20.*log10(abs(hf_ns));

    % Just looking at exact frequency of interest
    % new_amplitudes(:, whichf) = interp1(f_out, out, f_123(:,whichf));

    % Finds peak nearest the frequency of interest
    for j = 1:size(f_123,1)
        regionOfInterest = find(f_out > f_123(j, whichf)-1 & f_out < f_123(j, whichf)+1);
        [peakOfInterest, index] = max(out(regionOfInterest));
        new_amplitudes(j, whichf) = peakOfInterest;
        peakIndex(j, whichf) = regionOfInterest(index);
    end

    % Find noise floor (using the calculated frequency)
    %idx = find(round(f_out) >=round(dp_freq(whichf)),1);
    %noise(whichf) = mean(out([idx-6:idx-2, idx+2:idx+6]));

    % Find noise floor (using the peak as the freq of interest)
    idx = peakIndex(3,whichf);
    noise(whichf) = mean(out([idx-5:idx-1,idx+1:idx+5]));

    % Can we also eliminate the stimulus from the spectrum for dpoae amplitude
    % calculation?
    stim1 = sin(2*pi*f1(whichf)*t)'; % create the stimulus
    stim1(1:floor(numel(ramp)/2)) = stim1(1:floor(numel(ramp)/2)) .* ramp(1:floor(numel(ramp)/2));
    stim1((end-floor(numel(ramp)/2) + 1):end) = stim1((end-floor(numel(ramp)/2) + 1):end) .* ramp(1:floor(numel(ramp)/2));
    stim2 = sin(2*pi*f2(whichf)*t)'; % create the stimulus
    stim2(1:floor(numel(ramp)/2)) = stim2(1:floor(numel(ramp)/2)) .* ramp(1:floor(numel(ramp)/2));
    stim2((end-floor(numel(ramp)/2) + 1):end) = stim2((end-floor(numel(ramp)/2) + 1):end) .* ramp(1:floor(numel(ramp)/2));
    stim1 = [stim1(:); pad(:)];
    stim2 = [stim2(:); pad(:)];

    idx1 = find(round(f_out) >=round(f1(whichf)),1);
    amp_f1 = abs(hf_fft1(1,idx1));
    idx2 = find(round(f_out) >=round(f2(whichf)),1);
    amp_f2 = abs(hf_fft1(1,idx2));

    stim1 = amp_f1 .* stim1;
    stim2 = amp_f2 .* stim2;

    fft_f1(whichf, 1:N_signal2) = fft(w.*stim1, N_signal2);
    fft_f2(whichf, 1:N_signal2) = fft(w.*stim2, N_signal2);

    % for the plots
    hf_fft1_f1 = fft_f1(whichf,1:numel(f_out)).*2;
    hf_fft_f1 = hf_fft1_f1./(ppval(pp.micSens, f_out).*ref);
    out_f1 = 20.*log10(abs(hf_fft_f1));
    hf_fft1_f2 = fft_f2(whichf,1:numel(f_out)).*2;
    hf_fft_f2 = hf_fft1_f2./(ppval(pp.micSens, f_out).*ref);
    out_f2 = 20.*log10(abs(hf_fft_f2));

    clean_dp = hf_fft - (hf_fft_f1 + hf_fft_f2);

    out_clean_dp = out - (out_f1 + out_f2);

    if plot_yes
        figure(11);
        subplot(2,3,whichf)
        hold on;
        fill([200, 200, 8000.*1.2, 8000.*1.2], [-40, noise(whichf), noise(whichf), -40], [.8, .8, .8])
        plot(f_out, out, 'k')
        %plot(f_out, out_f1, 'Color',[138, 45, 64, 200]./255)
        %plot(f_out, out_f2, 'Color', [20, 10, 125, 200]./255)
        xlim([f_123(3,whichf).*.80,f_123(2, whichf).*1.2])
        ylim([-40, 70])
        xticks([round(f_123([3,1,2],whichf))])
        hold on;
        plot(f_123(:,whichf), [f1_rec_dB(whichf), f2_rec_dB(whichf), DP(whichf)], 'ro', 'MarkerSize', 4, 'LineWidth', 1, 'Color', [.65,.65,.65])
        plot(f_out(1,peakIndex(:,whichf)), [new_amplitudes(1, whichf), new_amplitudes(2,whichf), new_amplitudes(3,whichf)], 'x', 'MarkerSize',6, 'Color',[0.3216    0.1765    0.6118], 'LineWidth',1)
        set(gca, 'XScale', 'log')
        xlabel('Frequency (Hz)')
        ylabel('Amplitude (dB SPL)')
        title(sprintf('F2 = %d', f_123(2,whichf)))
        %legend('Full resp.', 'F1', 'F2', 'Orig.','New Amps.', 'NoiseFloor')
    end

end

%% Compare old data to new calculation
ms =10;
if plot_yes
    figure; hold on;
    plot(f_123(1,:), f1_rec_dB(1,:), 's-', "Color", [.8, .8, .8], 'LineWidth',1.5, 'MarkerSize', ms)
    plot(f_123(2,:), f2_rec_dB(1,:), '^-', "Color", [.8, .8, .8], 'LineWidth',1.5, 'MarkerSize', ms)
    plot(f_123(2,:), DP(1,:), 'x-', "Color", [.8, .8, .8], 'LineWidth',1.5, 'MarkerSize', ms)
    plot(f_123(2,:), noisefloor_dp, 'x--', "Color", [.8, .8, .8], 'LineWidth',1.5, 'MarkerSize', ms)
    plot(f_123(1,:), new_amplitudes(1,:), 's-', "Color", [0.3216    0.1765    0.6118], 'LineWidth',2, 'MarkerSize', ms)
    plot(f_123(2,:), new_amplitudes(2,:), '^-', "Color", [0.3216    0.1765    0.6118], 'LineWidth',2, 'MarkerSize', ms)
    plot(f_123(2,:), new_amplitudes(3,:), 'x-', "Color", [0.3216    0.1765    0.6118], 'LineWidth',2, 'MarkerSize', ms)
    plot(f_123(2,:), noise, 'x--', "Color", [0.3216    0.1765    0.6118], 'LineWidth',2, 'MarkerSize', ms)
    %legend('F_1','F_2','DP','Noise Floor');
    set(gca,'XScale','log');
    set(gcf,'Position',[100 100 600 400],'Units','pixels')
    xlabel('Frequency (Hz)');
    ylabel('DP (dB SPL)');
    xlim([.8e3,10e3])
    ylim([-40, 70])
    xticks([1000, 2000, 4000, 8000])
    grid on
end

output.f1 = oae_data.f1;
output.f2 = oae_data.f2;
output.f1_rec_dB = new_amplitudes(1,:);
output.f2_rec_dB = new_amplitudes(2,:);
output.DP = new_amplitudes(3,:);
output.noisefloor_dp =noise;
output.mean_response = oae_data.mean_response;
output.fs = oae_data.fs;
output.raw_responses = oae_data.raw_responses;

end