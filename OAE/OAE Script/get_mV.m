function [mV] = get_mV(freq,dB)
%Calibration for speaker 1 and 2. 
%   mV = amplitudes in mV for a given dB for speaker 1 and 2
%   depends on calibration coefficients from oae_spk_1_calib.mat and oae_spk_2_calib.mat 

%Tested mV output from Matlab during calibration
calib_mV = 300;

load oae_spk_1_calib.mat oae_spk_1_calib;
load oae_spk_2_calib.mat oae_spk_2_calib;

coeff_1 = interp1(oae_spk_1_calib(:,1),oae_spk_1_calib(:,3),freq(1));
coeff_2 = interp1(oae_spk_2_calib(:,1),oae_spk_2_calib(:,3),freq(2));

mV(1) = calib_mV.*db2mag(dB(1)-coeff_1);
mV(2) = calib_mV.*db2mag(dB(2)-coeff_2);

clear oae_spk_1_calib oae_spk_2_calib;

end

