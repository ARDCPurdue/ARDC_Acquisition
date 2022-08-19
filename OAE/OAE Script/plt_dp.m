function plt_dp(fname, dataDir)

pd = pwd;
cd(dataDir);
load(fname);

%can remove this after we delete initial data saved without F1
f1 = f2./1.22;

    hold on
    plot(f1,f1_rec_dB,'kx-','LineWidth', 1);
    plot(f2,f2_rec_dB,'ks-','LineWidth', 1);
    plot(f2,DP,'k-o','LineWidth',1.5);
    plot(f2,noisefloor_dp,'r-','LineWidth',1.5);
    legend('F_1','F_2','DP','Noise Floor'); 
    set(gca,'XScale','log');
    set(gcf,'Position',[1925,-5,1920,1200])
    xlabel('Frequency (Hz)');
    ylabel('DP (dB SPL)');
    xlim([500,10e3])
    ylim([-60,70])
    grid on 
    
    hold off
    
title('DP Gram')

cd(pd)

end

