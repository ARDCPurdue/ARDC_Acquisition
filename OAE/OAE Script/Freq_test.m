
clear all;
clc;
close all;

addpath([pwd '\i3'])
load TransducerCalIOWA.mat

fs = 44.1e3;
OAEI = OAE_Interface(fs);
dur = 1.0;
l_stim = dur*fs;
trials_min = 16;
trials_max = 32;

f2 = [2e3];
% f1 = f2;

f1 = f2./1.22;
f3 = 2*f1-f2;

%dB for F1 and F2
dB = [65,55];
mV_amp = get_mV([f1,f2],[dB(1),dB(2)]);

OAEI.StartTrial(f1,f2,mV_amp,1000);
pause(dur);
OAEI.StopTrial();

OAE_response = reshape(OAEI.response.',[],1);

