function [filename, researcher, start_time] = get_fname_reflex(protocol,dataDir)

prompt = {'Subject ID: ','Researcher Initials: '};
%manual entry
entries = inputdlg(prompt);
researcher = entries{2};

start_time = datetime('now');
start_time.Format = 'MMddyyyy';

% filename = strcat(entries{1},'_',protocol,'_',side,'_',num2str(month(start_time)),'_',num2str(day(start_time)),'_',num2str(year(start_time)));
filename = strcat(entries{1},'_',string(start_time),'_',protocol);
%check for duplicates

files = dir(fullfile(dataDir,'*.mat'));

%better way to do this???
for i = 1:length(files)
    if strcmp(files(i).name,strcat(filename,'.mat'))
        input = questdlg('Previous Data found...Overwrite? ','Overwrite?','Yes','No','No');
        if strcmp(input,'No')
            error('Previous Data found...not overwriting.');
        end
    end
    
end

end

