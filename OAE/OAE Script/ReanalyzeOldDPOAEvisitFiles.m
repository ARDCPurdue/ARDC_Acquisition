%% Reanalyze Old OAEs
% In the original data collection code, there was an issue with ramping
% which led to two clicks at the end of each stimulus presentation. This
% code will load in old ARDC visit structure files, re-analyze the OAE data
% and re-save them.
% Created by: Samantha Hauser, December 2025

%% Set the directories
%OLDdir = "C:\Users\ARDC User\Desktop\FinalCompiled\ARDC\"; % Replace this with the folder where the original visit files are stored
%NEWdir = "C:\Users\ARDC User\Desktop\FinalCompiled\ARDC\newOAE\";

OLDdir = 'C:\Users\saman\Downloads\ARDC-selected\'; % Replace this with the folder where the original visit files are stored
NEWdir = 'C:\Users\saman\Downloads\oae\';

%% Get the list of all of the visit files
oldVisitFiles = dir([OLDdir, 'ARDC*.mat']);

%% Loop through each file, get the old OAE data, reanalyze, resave
for i = 1:numel(oldVisitFiles)

    % Load the visit file
    visitFile = [oldVisitFiles(i).folder, '\', oldVisitFiles(i).name];
    load(visitFile)

    % check if DPOAE is a field
    if isfield(visit.Measures, "DPOAE")

        for k = ["R", "L"] % loop through the two ears
            if isfield(visit.Measures.DPOAE, k) % Do the right ear first
                % get names as expected for alt_OAEanalysis
                visit.Measures.DPOAE.(k).noisefloor_dp = visit.Measures.DPOAE.R.noisefloor;
                output = revisedDPOAEanalysis(visit.Measures.DPOAE.(k), 0);
                visit.Measures.DPOAE.(k) = output;
                save([NEWdir, oldVisitFiles(i).name], "visit")
            end
        end

    else 
        % if DPOAE is not a field, then we should just re-copy the file into the new directory
        save([NEWdir, oldVisitFiles(i).name], "visit")
    end

end
