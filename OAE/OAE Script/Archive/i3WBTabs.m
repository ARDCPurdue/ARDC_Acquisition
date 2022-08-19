clear; clc; close all;
addpath([pwd '\i3'])
addpath([pwd '\WBT'])

%% Create WBT absorbance object to work on
%wbt_abs = WBTabsTest('adult');
wbt_abs = WBTabsTest('infant');

% Run calibration routine
absorbance = wbt_abs.Run();