clear; clc; close all;
addpath([pwd '\i3'])
addpath([pwd '\WBT'])

%% Infant calibration
% Create WBTcal object to work on
wbt_levcal = WBTlevCalTest('adult');
wbt_cal = WBTcalTest('adult');

% Run adult calibration routine
wbt_levcal.Run() 
wbt_cal.Run()
 