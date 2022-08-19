%Just creating a test script to make sure microphone and speaker are
%working

%TODO: Write new calibration code
%Add sweep? Get peak detection working properly. Use Hari's Code
%Test all F2 in ARDC protocol
%Add thresholding and set trial number based on the thresholding
%Make a cleaner object if possible


clear all;
clc;
close all;

addpath([pwd '\i3'])

%creating a new trial

%fs = 22050;
fs = 44.1e3;
tr = InputOutput(fs);
dur = 1.0;
l_stim = dur*fs;
trials = 10;

f1 = 1000/1.22;
f2 = 1000;

f3 = 2*f1-f2;

nfft = 15000;

dB = 70;

mV = 300*db2mag(dB-107.36);

for i = 1:trials
tr.StartStimulation(f1,f2,mV,512);
pause(dur);
tr.StopStimulation();

response = reshape(tr.response.',[],1);
%response = tr.response.';
%pressure = reshape(tr.pressure.',[],1);
[DFTsigt, DFTfreq_Hz, ~, ~] = compute_dft(response,fs,[],[],nfft,'dB');
DFTsig_tr(i,:) = DFTsigt; 
plot(DFTfreq_Hz,DFTsigt)
end 

DFTsig = mean(DFTsig_tr,1);
%calculate OAE in dB
% ind = find(round(DFTfreq_Hz) == f1);
% f1_ind = (ind(1)-.02*nfft):(ind(1)+.02*nfft);
% [f1_peak,f1_loc] = max(DFTsig(f1_ind));
% 
% ind = find(round(DFTfreq_Hz) == f2);
% f2_ind = (ind(1)-.02*nfft):(ind(1)+.02*nfft);
% [f2_peak,f2_loc] = max(DFTsig(f2_ind));
% 
% ind = find(round(DFTfreq_Hz) == f3);
% f3_ind = (ind(1)-.005*nfft):(ind(1)+.005*nfft);
% [f3_peak,f3_loc] = max(DFTsig(f3_ind));

figure;
hold on
plot(DFTfreq_Hz,DFTsig)
% plot(f1,f1_peak,'o')
% plot(f2,f2_peak,'o')
% plot(f3,f3_peak,'o')
xlim([800,4000])
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
title('DPOAE 5 Trial Average - 2cc Tube - 5s/trial')

