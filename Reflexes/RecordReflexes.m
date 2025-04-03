%% Record reflexes that you measured on the Titan

% Where data should be saved
dataDir = 'C:\Users\ARDC User\Desktop\DATA';
orig_path = pwd;

% Initialize researcher and date
[filename, researcher, start_time] = get_fname_reflex('RFX',dataDir); 
filename = char(filename);

% Load GUI to enter the reflex thresholds
global output_reflex output_wrs output_act
getSelectedRadioButtons; 
uiwait(gcf)

% Save data
reflex_data.researcher = researcher;
reflex_data.time = start_time;
reflex_data = output_reflex; 
clear output_reflex; 

reflex_data.wrs = output_wrs; 
reflex_data.act = output_act; 
clear output_wrs; 
clear output_act; 

cd(dataDir)
save([filename,'.mat'],'-struct','reflex_data');

cd(orig_path);