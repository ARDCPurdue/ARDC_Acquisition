clear; clc; close all;
addpath([pwd '\i3'])
addpath([pwd '\WBT'])
addpath([pwd '\Utilities'])

cal_type = 'adult'; %'infant';

%% Create WBT Tymp test (3DT) object
wbt3dt_test = WBT3DTTest(cal_type);

% Set pressure sweep parameters for 3DT test
% Parameters: start_p, stop_p, tolerance, pump_speed
wbt3dt_test.Config(200, -300, 10, 300);

% Run 3DT test - result saved in data_3DT
data_3DT = wbt3dt_test.Run();

%% Create WBT Ipsi-lateral Reflex threshold test object
% Parameters: cal_type, activator levels (dB SPL), activator frequency, 
%             tympanic peak pressure, ipsi or contra lateral activator
ipsi_test = WBTreflexTest(cal_type, (75:5:95), 1000, data_3DT.TPP, 'ipsi');

% Run Reflex threshold test
reflex_ipsi = ipsi_test.Run();

%% Create WBT Contra-lateral Reflex threshold test object
% Parameters: cal_type, activator levels (dB SPL), activator frequency, 
%             tympanic peak pressure, ipsi or contra lateral activator
contra_test = WBTreflexTest(cal_type, (75:5:95), 1000, data_3DT.TPP, 'contra');

% Run Reflex threshold test
reflex_contra = contra_test.Run();
