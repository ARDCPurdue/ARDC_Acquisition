%% Compile Clinical Data
sub = 'ARDC1';

addpath(strcat('Data/03_26_2021/',sub,'/Clinical Data'));
load(strcat(sub,'_OAE.mat'));

L_dp = horzcat(L1(:,1),L2(:,1),L3(:,1));
L_nf = horzcat(L1(:,2),L2(:,2),L3(:,2));
R_dp = horzcat(R1(:,1),R2(:,1),R3(:,1));
R_nf = horzcat(R1(:,2),R2(:,2),R3(:,2));

L_dp_mean = mean(L_dp,2);
L_dp_sd = std(L_dp,0,2);

L_nf_mean = mean(L_nf,2);
L_nf_sd = std(L_nf,0,2);


R_dp_mean = mean(R_dp,2);
R_dp_sd = std(R_dp,0,2);

R_nf_mean = mean(R_nf,2);
R_nf_sd = std(R_nf,0,2);

%% Grab/plot 

%Left

figure;
dir = strcat('Data/03_26_2021/',sub,'/OAE');

[f2,L_DP(:,1),noisefloor_dp(:,1)] = plt_dp_gr(strcat(sub,'_1_OAE_L_3_26_2021.mat'),dir);
[~,L_DP(:,2),noisefloor_dp(:,2)] = plt_dp_gr(strcat(sub,'_2_OAE_L_3_26_2021.mat'),dir);
[~,L_DP(:,3),noisefloor_dp(:,3)] = plt_dp_gr(strcat(sub,'_3_OAE_L_3_26_2021.mat'),dir);
close all;

hold on
errorbar(freq(:,2), L_dp_mean, L_dp_sd,'--','color',[0,.5,1], 'LineWidth',1.5)
errorbar(freq(:,2), L_nf_mean, L_nf_sd,'--','color',[1,0.2,0.2], 'LineWidth',1.5)

errorbar(f2, mean(L_DP,2), std(L_DP,0,2),'b-', 'LineWidth',2)
errorbar(f2, mean(noisefloor_dp,2),std(noisefloor_dp,0,2),'r-', 'LineWidth',2);

[~,~,~] = plt_dp_gr(strcat(sub,'_1_OAE_L_3_26_2021.mat'),dir);
[~,~,~] = plt_dp_gr(strcat(sub,'_2_OAE_L_3_26_2021.mat'),dir);
[~,~,~] = plt_dp_gr(strcat(sub,'_3_OAE_L_3_26_2021.mat'),dir);

hold off
legend('Clinical DP','Clinical NF','ARDC DP','ARDC NF','F1','F2');
title(strcat(sub,' | Left DPOAE Comparison'));

%Right 

figure;
[f2,R_DP(:,1),noisefloor_dp(:,1)] = plt_dp_gr(strcat(sub,'_1_OAE_R_3_26_2021.mat'),dir);
[~,R_DP(:,2),noisefloor_dp(:,2)] = plt_dp_gr(strcat(sub,'_2_OAE_R_3_26_2021.mat'),dir);
[~,R_DP(:,3),noisefloor_dp(:,3)] = plt_dp_gr(strcat(sub,'_3_OAE_R_3_26_2021.mat'),dir);
close(2);

figure;
hold on
errorbar(freq(:,2), R_dp_mean, R_dp_sd,'--','color',[0,.5,1], 'LineWidth',1.5)
errorbar(freq(:,2), R_nf_mean, R_nf_sd,'--','color',[1,0.2,0.2],'LineWidth',1.5)

errorbar(f2, mean(R_DP,2), std(R_DP,0,2),'b-', 'LineWidth',2)
errorbar(f2, mean(noisefloor_dp,2),std(noisefloor_dp,0,2),'r-', 'LineWidth',2);

[~,~,~] = plt_dp_gr(strcat(sub,'_1_OAE_R_3_26_2021.mat'),dir);
[~,~,~] = plt_dp_gr(strcat(sub,'_2_OAE_R_3_26_2021.mat'),dir);
[~,~,~] = plt_dp_gr(strcat(sub,'_3_OAE_R_3_26_2021.mat'),dir);

hold off
legend('Clinical DP','Clinical NF','ARDC DP','ARDC NF','F1','F2');
title(strcat(sub,' | Right DPOAE Comparison'));