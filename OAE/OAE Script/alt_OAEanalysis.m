function alt_OAEanalysis(oae_data)

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
factor = 1./(mic_sens.*ref);

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
    avgnoise = mean(noiseresponse,2); 
    
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

%     figure; hold on;
%     plot(f_out, out)
%     xlim([200,8000])
%     ylim([-20, 80])
%     xticks([250, 500, 1000, 2e3, 4e3, 8e3])
%     hold on;
%     plot(f_123(:,whichf), [f1_rec_dB(whichf), f2_rec_dB(whichf), DP(whichf)], 'ro')
%     plot(f_out, out_ns, 'color', [.8,.8,.8]); 
%     set(gca, 'XScale', 'log')
     new_amplitudes(:, whichf) = interp1(f_out, out, f_123(:,whichf));

    idx = find(round(f_out) >=round(dp_freq(whichf)),1);
    noise(whichf) = mean(out([idx-6:idx-2, idx+2:idx+6]));

    % Can we also eliminate the stimulus from the spectrum for dpoae amplitude
    % calculation?
    % this stimulus calculation is with the bad ramping
%     stim1 = sin(2*pi*f1(whichf)*t)'; % create the stimulus
%     stim1(1:floor(numel(ramp)/2)) = stim1(1:floor(numel(ramp)/2)) .* ramp(1:floor(numel(ramp)/2));
%     stim1((end-floor(numel(ramp)/2) + 1):end) = stim1((end-floor(numel(ramp)/2) + 1):end) .* ramp(1:floor(numel(ramp)/2));
%     stim2 = sin(2*pi*f2(whichf)*t)'; % create the stimulus
%     stim2(1:floor(numel(ramp)/2)) = stim2(1:floor(numel(ramp)/2)) .* ramp(1:floor(numel(ramp)/2));
%     stim2((end-floor(numel(ramp)/2) + 1):end) = stim2((end-floor(numel(ramp)/2) + 1):end) .* ramp(1:floor(numel(ramp)/2));
%     stim1 = [stim1(:); pad(:)];
%     stim2 = [stim2(:); pad(:)];
    
    stim1 = sin(2*pi*f1(whichf)*t)'; % create the stimulus
    stim1(1:floor(numel(ramp)/2)) = stim1(1:floor(numel(ramp)/2)) .* ramp(1:floor(numel(ramp)/2));
    stim1((end-floor(numel(ramp)/2) + 1):end) = stim1((end-floor(numel(ramp)/2) + 1):end) .* ramp(floor(numel(ramp)/2+1:end));
    stim2 = sin(2*pi*f2(whichf)*t).'; % create the stimulus
    stim2(1:floor(numel(ramp)/2)) = stim2(1:floor(numel(ramp)/2)) .* ramp(1:floor(numel(ramp)/2));
    stim2((end-floor(numel(ramp)/2) + 1):end) = stim2((end-floor(numel(ramp)/2) + 1):end) .* ramp(floor(numel(ramp)/2+1:end));
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

    figure; hold on;
    plot(f_out, out_ns, 'color', [.8,.8,.8]); 
    plot(f_out, out, 'k')
    plot(f_out, out_f1, 'r')
    plot(f_out, out_f2, 'b')
    xlim([200,8000])
    ylim([-40, 80])
    xticks([250, 500, 1000, 2e3, 4e3, 8e3])
    hold on;
    plot(f_123(:,whichf), [f1_rec_dB(whichf), f2_rec_dB(whichf), DP(whichf)], 'ro')
    set(gca, 'XScale', 'log')
end

%% Compare old data to new calculation
ms =10;
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