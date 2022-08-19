clear; clc; close all;
addpath([pwd '\i3'])
addpath([pwd '\WBT'])

%% Infant calibration
% Create WBTcal object to work on
wbt_cal = WBTcalTest('infant');

% Run infant calibration routine
wbt_cal.Run()

%% Adult calibration
% Create WBTcal object to work on
wbt_cal = WBTcalTest('adult');

% Run adult calibration routine
wbt_cal.Run()