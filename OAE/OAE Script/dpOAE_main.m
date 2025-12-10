
%Script Designed to collect dpgram for a given subject using the
%Interacoustics Titan
%Created by: Andrew
%Updated: 08/2022
%Figure size changed by SH on 12/2023
%Based on code found in DPOAEgrowth.m from Hari:
% https://github.com/haribharadwaj/codebasket/blob/master/DPOAE_ER10X_SPL/DPOAEgrowth.m

clear all;
clc;
close all;

addpath([pwd '\i3'])
load TransducerCalIOWA.mat

%Be sure to update the dataPath as needed. All OAE data will be saved here.
dataPath = 'C:\Users\ARDC User\Desktop\DATA';

%check to make sure dataPath exists
if(exist(dataPath,'dir')==0)
    mkdir(dataPath);
end

orig_path = pwd;
%% Initialize Parameters:

%filename = inputdlg('Please enter a name to save mat file as: ');
[filename, researcher, start_time] = get_fname('OAE',dataPath);
filename = char(filename);

%creating a new trial
fs = 44100;
OAEI = OAE_Interface(fs);
dur = .5;
l_stim = dur*fs;
trials_min = 16;
trials_max = 32;

%f2 = [1e3,2e3,4e3,8e3];

%Boystown Freqs
f2 = [1e3, 2344, 3750, 4781, 6e3, 8e3];
% f1 = f2;

f1 = f2./1.22;
f3 = 2*f1-f2;

%dB for F1 and F2
dB = [65,55];

%Setup
noisefloor_dp = zeros(1,length(f2));
DP = zeros(1,length(f2));
f1_rec_dB = zeros(1,length(f2));
f2_rec_dB = zeros(1,length(f2));

%% Run dpOAEs:

dpfig = figure;
xticks(f2);
xlabel('Frequency (Hz)');
ylabel('DP (dB SPL)');
xlim([1e3,10e3])
set(gca,'XScale','log');
grid on
set(gcf,'Position',[100 500 600 400],'Units','pixels')

hold on
plot(f1,dB(1)*ones(1,length(f1)),'kx-','LineWidth', 1);
plot(f2,dB(2)*ones(1,length(f2)),'ks-','LineWidth', 1);
plot(f2,DP,'k-o','LineWidth',1.5);
plot(f2,noisefloor_dp,'r-','LineWidth',1.5);
title('DP Gram');
legend('F_1','F_2','DP','Noise Floor'); 
hold off

press = zeros(100,1);

try
    while(max(press)<50)
            disp('Place probe in ear')
            OAEI.SetPressure(50,20,0);
            press = OAEI.pressure;
    end        
    OAEI.SetPressure(0,20,0);
    disp('Probe in ear!')
catch
    error('Cannot set pressure. Is device turned on and connected?')
end

for i = 1:length(f2)
    disp(['Frequency (F2): ', num2str(f2(i))])
    %Apply calibration coefficients to get right mV outputs
    %FIX
    mV_amp = get_mV([f1(i),f2(i)],[dB(1),dB(2)]);
    
    trial_f = 0;
    stillCollect = true;
    
    while(stillCollect && (trial_f < trials_max))
       
        disp(['Trial: ', num2str(trial_f)]);
        
        OAEI.StartTrial(f1(i),f2(i),mV_amp,round(fs*dur),trials_min);
        
        % Wait for 20% extra
        while ~OAEI.IsDone
            pause(0.05);
        end
        OAEI.StopTrial();
        trial_f = trial_f + trials_min;
        
        %OAE_response(:,trial_f) = reshape(OAEI.response.',[],1);
        OAE_response = OAEI.response';
        if(trial_f >= trials_min)
            
            OAE_noise = OAE_response;
            OAE_noise(:,2:2:end) = -1*OAE_noise(:,2:2:end);
            
            noise = mean(OAE_noise,2);
            signal = mean(OAE_response,2);
            
            w = dpss(numel(noise),1,1)';
            w = w/sum(w);
            
            %%%% CHANGE TO F3
            %f_dp = f3(i);
            
            f_123 = [f1(i),f2(i),f3(i)];
            
            t_calc = (0:(numel(noise)-1))/fs;
            wsn = w.*sin(2*pi*f_123'*t_calc);
            wcn = w.*cos(2*pi*f_123'*t_calc);
            
            %freq in Hz 
            mic_sens = abs(ppval(pp.micSens,f_123)); %mV/Pa
            ref = 20e-6; %reference value of p0 in Pa
            factor = 1./(mic_sens.*ref);
            
            noisefloor_all = db(sqrt(sum(wsn'.*noise).^2 + sum(wcn'.*noise).^2).* factor);
            noisefloor_dp(i) = noisefloor_all(3);
            all_mags =  db(sqrt(sum(wsn'.*signal).^2 + sum(wcn'.*signal).^2).* factor);
            
            f1_rec_dB(i) = all_mags(1);
            f2_rec_dB(i) = all_mags(2);
            DP(i) = all_mags(3);
            
            nfloor = noisefloor_dp(i)
            
            %plot(f2(i),DP(i),'bo')
            
            if(nfloor < -25)
                stillCollect = false;
            end
            
        end
        %plot(oae_response);
    end
    
    %     plot(f2(i),DP(i),'ko','MarkerSize',13)
    OAE_mean_response(:,i) = mean(OAE_response,2);
    trials_collected(i) = trial_f;
    
    close(dpfig)
    dpfig = figure;
    hold on
    plot(f1,f1_rec_dB,'kx-','LineWidth', 1);
    plot(f2,f2_rec_dB,'ks-','LineWidth', 1);
    plot(f2,DP,'k-o','LineWidth',1.5);
    plot(f2,noisefloor_dp,'r-','LineWidth',1.5);
    legend('F_1','F_2','DP','Noise Floor'); 
    set(gca,'XScale','log');
    set(gcf,'Position',[100 500 600 400],'Units','pixels')
    xlabel('Frequency (Hz)');
    ylabel('DP (dB SPL)');
    xlim([1e3,10e3])
    grid on 
    
    hold off
    
end

oae_data.researcher = researcher;
oae_data.time = start_time;

oae_data.f1 = f1;
oae_data.f2 = f2;
oae_data.f1_rec_dB = f1_rec_dB;
oae_data.f2_rec_dB = f2_rec_dB;

oae_data.DP = DP;
oae_data.noisefloor_dp = noisefloor_dp;
oae_data.mean_response = OAE_mean_response;
oae_data.fs = fs;

cd(dataPath)
save([filename,'.mat'],'-struct','oae_data');

cd(orig_path);

%% Quick Plot of DPgram from mat file (make this a function later)

plt_dp([filename,'.mat'], dataPath);
