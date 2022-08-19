clear; clc; close all;
addpath([pwd '\i3'])
addpath([pwd '\WBT'])

%% Create TympTest object to work on
wbt3dt_test = WBT3DTTest('adult');
%wbt3dt_test = WBT3DTTest('infant');

% Set pressure sweep parameters
wbt3dt_test.Config(200, -300, 10, 300);  % tymptest.Config( start_pressure, stop_pressure, tolerance, pump_speed )
data = wbt3dt_test.Run();