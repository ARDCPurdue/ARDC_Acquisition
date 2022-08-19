function [f2,DP,noisefloor_dp] = plt_dp_gr(fname, dataDir)

pd = pwd;
cd(dataDir);
load(fname);

%can remove this after we delete initial data saved without F1
f1 = f2./1.22;
    alph = .7;
    hold on
    plot(f1,f1_rec_dB,'kx-','LineWidth', 1);
    plot(f2,f2_rec_dB,'ks-','LineWidth', 1);
    plot(f2,DP,'-o','color',[0,.05,.25]*.7+alph,'LineWidth',1.5);
    plot(f2,noisefloor_dp,'-','color',[.25,0.05,0.05]*.7+alph,'LineWidth',1.5);
    %legend('F_1','F_2','DP','Noise Floor'); 
    set(gca,'XScale','log');
    set(gcf,'Position',[1925,-5,1920,1200])
    xlabel('Frequency (Hz)');
    ylabel('DP (dB SPL)');
    xlim([500,10e3])
    ylim([-60,70])
    grid on 
        
title('DP Gram')

cd(pd)

end

