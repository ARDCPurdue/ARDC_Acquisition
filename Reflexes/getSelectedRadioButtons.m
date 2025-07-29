function getSelectedRadioButtons
close all;
%Hacky, generally try to avoid global variables...just trying to make a
%quick gui - AS

global output_reflex output_wrs output_act

% Create the main figure
fig = figure('Name', 'Enter Results', 'NumberTitle', 'off', ...
    'Position', [100, 100, 1200, 700],'Units','Normalized');
% yheight orig = 550

% Create column headers
x_mg = 150;
y_mg = 220;
width_mg = 320;
height_mg = 25;
xoffset_mg = 550;
yoffset_mg = 225;

%% Adding features for WRS, ACT

% Word Recognition Score Panel
wrsPanel = uipanel('Title', 'Word Recognition Score',...
    'Position', [0.05 0.8 0.9 0.2], ...
    'FontSize', 16);

% Add buttons, dropdowns, labels for WRS
wrs_EarLabelR = uicontrol('Parent', wrsPanel, 'Style', 'text',...
    'String', 'Right:',  'HorizontalAlignment', 'right', ...
    'FontSize', 14, 'ForegroundColor', 'r', 'Position', [105 50 50 30]);
wrs_ListLabelR = uicontrol('Style', 'text', 'Parent', wrsPanel, 'String', 'List:', ...
    'Position', [160 75 150 25], 'HorizontalAlignment', 'left', ...
    'FontSize', 12);
wrs_ListDropdownR = uicontrol('Style', 'popupmenu', 'Parent', wrsPanel, ...
    'String', {'NU-6 Ordered by Difficulty', 'NU-6', 'CNC'}, ...
    'Position', [160 55 150 25], ...
    'FontSize', 12);
wrs_ListNumLabelR = uicontrol('Style', 'text', 'Parent', wrsPanel, ...
    'String', 'List #:', ...
    'Position', [315 75 70 25], 'HorizontalAlignment', 'left', ...
    'FontSize', 12);
wrs_ListNumEntryR = uicontrol('Style', 'popupmenu', 'Parent', wrsPanel, ...
    'Position', [315 55 70 25], ...
    'String',{'1', '2','3','4'}, 'Value', 2, ...
    'FontSize', 12);
wrs_NumCorrectLabelR = uicontrol('Style', 'text', 'Parent', wrsPanel, 'String', 'Correct:', ...
    'Position', [405 75 70 25], 'HorizontalAlignment', 'left', ...
    'FontSize', 12);
wrs_NumCorrectEntryR = uicontrol('Style', 'edit', 'Parent', wrsPanel, ...
    'Position', [405 55 70 25], ...
    'FontSize', 12);
wrs_TotalWordsLabelR = uicontrol('Style', 'text', 'Parent', wrsPanel, 'String', 'Total:', ...
    'Position', [480 75 70 25], 'HorizontalAlignment', 'left',...
    'FontSize', 12);
wrs_TotalDropdownR = uicontrol('Style', 'popupmenu', 'Parent', wrsPanel, ...wrc
    'String', {'10', '25', '50'}, 'Position', [480 55 70 25], 'Value', 1,...
    'FontSize', 12);
wrs_LevelLabelR = uicontrol('Style', 'text', 'Parent', wrsPanel, 'String', 'Level:', ...
    'Position', [405 25 70 25], 'HorizontalAlignment', 'left', ...
    'FontSize', 12);
wrs_LevelEntryR = uicontrol('Style', 'edit', 'Parent', wrsPanel, ...
    'Position', [405 5 70 25], ...
    'FontSize', 12);
wrs_MaskingLabelR = uicontrol('Style', 'text', 'Parent', wrsPanel, 'String', 'Masking:', ...
    'Position', [480 25 70 25], 'HorizontalAlignment', 'left',...
    'FontSize', 12);
wrs_MaskingEntryR = uicontrol('Style', 'edit', 'Parent', wrsPanel, ...
    'Position', [480 5 70 25],...
    'FontSize', 12);
wrs_checkR = uicontrol('Style', 'checkbox', 'Parent', wrsPanel, 'Value', 1, ...
    'Position', [80 58 20 20], 'Callback', {@rightCheckCallback,wrs_ListLabelR, wrs_ListDropdownR,...
    wrs_ListNumLabelR,wrs_ListNumEntryR, wrs_NumCorrectLabelR, ...
    wrs_NumCorrectEntryR, wrs_TotalWordsLabelR, wrs_TotalDropdownR, ...
    wrs_LevelLabelR, wrs_LevelEntryR, wrs_MaskingLabelR, wrs_MaskingEntryR });

left_offset = [500 0 0 0];
wrs_EarLabelL = uicontrol('Parent', wrsPanel, 'Style', 'text',...
    'String', 'Left:',  'HorizontalAlignment', 'right', ...
    'FontSize', 14, 'ForegroundColor', 'b', 'Position', wrs_EarLabelR.Position + left_offset);
wrs_ListLabelL = uicontrol('Style', 'text', 'Parent', wrsPanel, 'String', 'List:', ...
    'Position', wrs_ListLabelR.Position + left_offset, 'HorizontalAlignment', 'left', ...
    'FontSize', 12);
wrs_ListDropdownL = uicontrol('Style', 'popupmenu', 'Parent', wrsPanel, ...
    'String', {'NU-6 Ordered by Difficulty', 'NU-6', 'CNC'}, ...
    'Position', wrs_ListDropdownR.Position + left_offset, ...
    'FontSize', 12);
wrs_ListNumLabelL = uicontrol('Style', 'text', 'Parent', wrsPanel, 'String', 'List #:', ...
    'Position', wrs_ListNumLabelR.Position + left_offset, 'HorizontalAlignment', 'left', ...
    'FontSize', 12);
wrs_ListNumEntryL = uicontrol('Style', 'popupmenu', 'Parent', wrsPanel, ...
    'Position', wrs_ListNumEntryR.Position + left_offset, ...
    'String',{'1', '2','3','4'}, 'Value', 1, ...
    'FontSize', 12);
wrs_NumCorrectLabelL = uicontrol('Style', 'text', 'Parent', wrsPanel, 'String', 'Correct:', ...
    'Position', wrs_NumCorrectLabelR.Position + left_offset, 'HorizontalAlignment', 'left', ...
    'FontSize', 12);
wrs_NumCorrectEntryL = uicontrol('Style', 'edit', 'Parent', wrsPanel, ...
    'Position', wrs_NumCorrectEntryR.Position + left_offset, ...
    'FontSize', 12);
wrs_TotalWordsLabelL = uicontrol('Style', 'text', 'Parent', wrsPanel, 'String', 'Total:', ...
    'Position', wrs_TotalWordsLabelR.Position + left_offset, 'HorizontalAlignment', 'left',...
    'FontSize', 12);
wrs_TotalDropdownL = uicontrol('Style', 'popupmenu', 'Parent', wrsPanel, ...
    'String', {'10', '25', '50'}, 'Position', wrs_TotalDropdownR.Position + left_offset, 'Value', 1,...
    'FontSize', 12);
wrs_LevelLabelL = uicontrol('Style', 'text', 'Parent', wrsPanel, 'String', 'Level:', ...
    'Position', wrs_LevelLabelR.Position + left_offset, 'HorizontalAlignment', 'left', ...
    'FontSize', 12);
wrs_LevelEntryL = uicontrol('Style', 'edit', 'Parent', wrsPanel, ...
    'Position', wrs_LevelEntryR.Position + left_offset, ...
    'FontSize', 12);
wrs_MaskingLabelL = uicontrol('Style', 'text', 'Parent', wrsPanel, 'String', 'Masking:', ...
    'Position', wrs_MaskingLabelR.Position + left_offset, 'HorizontalAlignment', 'left',...
    'FontSize', 12);
wrs_MaskingEntryL = uicontrol('Style', 'edit', 'Parent', wrsPanel, ...
    'Position', wrs_MaskingEntryR.Position + left_offset,...
    'FontSize', 12);
wrs_checkL = uicontrol('Style', 'checkbox', 'Parent', wrsPanel, 'Value', 1, ...
    'Position', wrs_checkR.Position + left_offset + [10 0 0 0], 'Callback', {@leftCheckCallback,wrs_ListLabelL, wrs_ListDropdownL,...
    wrs_ListNumLabelL,wrs_ListNumEntryL, wrs_NumCorrectLabelL, ...
    wrs_NumCorrectEntryL, wrs_TotalWordsLabelL, wrs_TotalDropdownL, ...
    wrs_LevelLabelL, wrs_LevelEntryL, wrs_MaskingLabelL,  wrs_MaskingEntryL});

actPanel = uipanel('Title', 'ACT', ...
    'Position', [0.05 0.72 0.9 0.07], ...
    'FontSize', 14);
act_Label1 = uicontrol('Style', 'text', 'Parent', actPanel, 'String', 'Trial 1:', ...
    'Position', [120 5 50 20], 'HorizontalAlignment', 'Right', ...
    'FontSize', 12);
act_Score1 = uicontrol('Style', 'edit', 'Parent', actPanel, ...
    'Position', [175 5 40 20], ...
    'FontSize', 12);
act_Label2 = uicontrol('Style', 'text', 'Parent', actPanel, 'String', 'Trial 2:', ...
    'Position', [270 5 50 20], 'HorizontalAlignment', 'Right', ...
    'FontSize', 12);
act_Score2 = uicontrol('Style', 'edit', 'Parent', actPanel, ...
    'Position', [325 5 40 20], ...
    'FontSize', 12);
act_LabelCNT = uicontrol('Style', 'text', 'Parent', actPanel, 'String', 'Could not test:', ...
    'Position', [425 5 150 20], 'HorizontalAlignment', 'Right', ...
    'FontSize', 12);
act_checkCNT = uicontrol('Style', 'checkbox', 'Parent', actPanel, 'Value', 0, ...
    'Position',[ 580 4 20 20 ]);
act_LabelDNT = uicontrol('Style', 'text', 'Parent', actPanel, 'String', 'Did not test:', ...
    'Position', [650 5 150 20], 'HorizontalAlignment', 'Right', ...
    'FontSize', 12);
act_checkDNT = uicontrol('Style', 'checkbox', 'Parent', actPanel, 'Value', 0, ...
    'Position',[ 805 4 20 20 ]);

%% For MEMR
% Define frequencies and levels
frequencies = {'.5', '1', '2', '4'};
levels = {'70', '75', '80', '85', '90', '95', '100', '105','110','115', 'CNT', 'NR'};
conditions = {'Right Contra', 'Left Contra', 'Right Ipsi', 'Left Ipsi'};

colHeader_RC = uicontrol('Style', 'text', 'String', conditions{1}, 'Position', [x_mg, y_mg+25, width_mg, height_mg], 'HorizontalAlignment', 'center', 'FontSize', 16, 'ForegroundColor', 'r');
colHeader_LC = uicontrol('Style', 'text', 'String', conditions{2}, 'Position', [x_mg+xoffset_mg, y_mg+25, width_mg, height_mg], 'HorizontalAlignment', 'center', 'FontSize', 16, 'ForegroundColor', 'b');
colHeader_RI = uicontrol('Style', 'text', 'String', conditions{3}, 'Position', [x_mg, y_mg+yoffset_mg+25, width_mg, height_mg], 'HorizontalAlignment', 'center', 'FontSize', 16, 'ForegroundColor', 'r');
colHeader_LI = uicontrol('Style', 'text', 'String', conditions{4}, 'Position', [x_mg+xoffset_mg, y_mg+yoffset_mg+25, width_mg, height_mg], 'HorizontalAlignment', 'center', 'FontSize', 16, 'ForegroundColor', 'b');

colSubHeader_RC = uicontrol('Style', 'text', 'String', 'Probe Right, Stim Left', 'Position', [x_mg, y_mg, width_mg, height_mg], 'HorizontalAlignment', 'center', 'FontSize', 14);
colSubHeader_LC = uicontrol('Style', 'text', 'String', 'Probe Left, Stim Right', 'Position', [x_mg+xoffset_mg, y_mg, width_mg, height_mg], 'HorizontalAlignment', 'center', 'FontSize', 14);
colSubHeader_RI = uicontrol('Style', 'text', 'String', 'Probe Right, Stim Right', 'Position', [x_mg, y_mg+yoffset_mg, width_mg, height_mg], 'HorizontalAlignment', 'center', 'FontSize', 14);
colSubHeader_LI = uicontrol('Style', 'text', 'String', 'Probe Left, Stim Left', 'Position', [x_mg+xoffset_mg, y_mg+yoffset_mg, width_mg, height_mg], 'HorizontalAlignment', 'center', 'FontSize', 14);

offs = [0,0;1,0;0,1;1,1];

for g = 1:4
    for j = 1:numel(levels)
        x = (j - 1) * 40 + 90;
        x = x+offs(g,1)*xoffset_mg;
        y = 193+offs(g,2)*yoffset_mg;
        uicontrol('Style', 'text', 'String', levels{j}, 'Position', [x, y, 45, 20], 'HorizontalAlignment', 'left', 'FontSize', 12);
    end
end

% Create a matrix to store radio button handles
radioHandles = zeros(numel(frequencies), numel(levels), 4);

% Initialize a matrix to store selected states
selectedMatrix = zeros(numel(frequencies), numel(levels), 4);

% Create row headers and radio buttons
for g2 = 1:4
    for i = 1:numel(frequencies)
        y = (numel(frequencies) - i) * 30 + 70;
        y = y+offs(g2,2)*yoffset_mg;
        x = 60 + offs(g2,1)*xoffset_mg;
        % Create row label
        uicontrol('Style', 'text', 'String', frequencies{i}, 'Position', [x, y+6, 30, 20], 'HorizontalAlignment', 'center', 'FontSize', 12);

        % Create radio buttons for each level in the current row
        for j = 1:numel(levels)
            x = (j - 1) * 40 + 90;
            x = x+offs(g2,1)*xoffset_mg;
            radioHandles(i, j, g2) = uicontrol('Style', 'radiobutton', 'Position', [x, y, 40, 30], 'Callback', @(src, event) radioButtonCallback(src, event, i, j, levels, g2), 'String', '', 'HorizontalAlignment', 'left', 'Value', 0);
        end
    end
end

% Button to trigger updating the matrix

buttonStatus = 'off';
updateButton = uicontrol('Style', 'pushbutton', 'String', 'Update Matrix',...
    'Position', [520, 15, 160, 50],'FontSize', 16,  ...
    'Callback', @(~, ~) updateAndPrint(levels), ...
    'Enable', buttonStatus, 'BackgroundColor', [220, 220, 220]./255);

% Callback function for radio buttons
    function radioButtonCallback(~, ~, rowIndex, colIndex, levels, cond)
        % Update the selected state in the matrix
        selectedMatrix(rowIndex, :, cond) = 0;
        selectedMatrix(rowIndex, colIndex, cond) = get(radioHandles(rowIndex,colIndex, cond),'Value');

        % Unselect other buttons in the same row
        set(radioHandles(rowIndex, setdiff(1:numel(levels), colIndex),cond), 'Value', 0);

        enable_exit = sum(selectedMatrix,"all")==16;

        switch enable_exit
            case 1
                buttonStatus = 'on';
                colorStatus = [0, 171, 102]./255;
            case 0
                buttonStatus = 'off';
                colorStatus = [220, 220, 220]./255;
        end
        updateButton = uicontrol('Style', 'pushbutton', 'String', 'Update Matrix', ...
            'Position', [520, 15, 160, 50], 'FontSize', 16, ...
            'Callback', @(~, ~) updateAndPrint(levels, ...
                wrs_LevelEntryR, wrs_MaskingEntryR, wrs_NumCorrectEntryR, wrs_TotalDropdownR, wrs_ListDropdownR, wrs_ListNumEntryR, ...
                wrs_LevelEntryL, wrs_MaskingEntryL, wrs_NumCorrectEntryL, wrs_TotalDropdownL, wrs_ListDropdownL, wrs_ListNumEntryL, ...
                act_Score1, act_Score2, act_checkDNT, act_checkCNT, wrs_checkR, wrs_checkL), ...
            'Enable',buttonStatus, 'BackgroundColor', colorStatus);
    end

% Function to update and print the matrix
    function updateAndPrint(levels, ...
            wrs_LevelEntryR, wrs_MaskingEntryR, wrs_NumCorrectEntryR, wrs_TotalDropdownR, wrs_ListDropdownR, wrs_ListNumEntryR, ...
            wrs_LevelEntryL, wrs_MaskingEntryL, wrs_NumCorrectEntryL, wrs_TotalDropdownL, wrs_ListDropdownL, wrs_ListNumEntryL, ...
            act_Score1, act_Score2, act_checkDNT, act_checkCNT, wrs_checkR, wrs_checkL)
        % Print the updated matrix in the command window
        for g3 = 1:4
            matrix = selectedMatrix(:,:,g3);
            [row_found,col_found] = find(matrix);
            lvl(g3,row_found) = levels(col_found);
        end

        lvl = string(lvl);

        %Convert to string
        output_reflex.Probe_R_Contra = lvl(1,:);
        output_reflex.Probe_L_Contra = lvl(2,:);
        output_reflex.Probe_R_Ipsi = lvl(3,:);
        output_reflex.Probe_L_Ipsi = lvl(4,:);

        %Get WRS data
        output_wrsR.speechLevel = get(wrs_LevelEntryR, 'String');
        output_wrsR.maskingLevel = get(wrs_MaskingEntryR, 'String');
        output_wrsR.correct = get(wrs_NumCorrectEntryR, 'String');
        all_totalwords = get(wrs_TotalDropdownR, 'String');
        output_wrsR.totalWords = all_totalwords{get(wrs_TotalDropdownR, 'Value')};
        all_lists = get(wrs_ListDropdownR, 'String');
        output_wrsR.list = all_lists{get(wrs_ListDropdownR, 'Value')};
        all_listnums = get(wrs_ListNumEntryR, 'String');
        output_wrsR.listNumber = all_listnums{get(wrs_ListNumEntryR, 'Value')};

        output_wrsL.speechLevel = get(wrs_LevelEntryL, 'String');
        output_wrsL.maskingLevel = get(wrs_MaskingEntryL, 'String');
        output_wrsL.correct = get(wrs_NumCorrectEntryL, 'String');
        all_totalwords = get(wrs_TotalDropdownL, 'String');
        output_wrsL.totalWords = all_totalwords{get(wrs_TotalDropdownL, 'Value')};
        all_lists = get(wrs_ListDropdownL, 'String');
        output_wrsL.list = all_lists{get(wrs_ListDropdownL, 'Value')};
        all_listnums = get(wrs_ListNumEntryL, 'String');
        output_wrsL.listNumber = all_listnums{get(wrs_ListNumEntryL, 'Value')};

        if get(wrs_checkL, 'Value') == 0    % if check is unchecked
            output_wrsL.didNotTest = 1;
        else
            output_wrsL.didNotTest = 0; 
        end

        if get(wrs_checkR, 'Value') == 0    % if check is unchecked
            output_wrsR.didNotTest = 1;
        else
            output_wrsR.didNotTest = 0; 
        end

        output_wrs.R = output_wrsR; 
        output_wrs.L = output_wrsL; 

        if get(act_checkDNT, 'Value') == 1
            output_act.didNotTest = 1;
        elseif get(act_checkCNT, 'Value') == 1
            output_act.couldNotTest = 1; 
        else
            output_act.didNotTest = 0; 
            output_act.couldNotTest = 0; 
        end
        output_act.score = {get(act_Score1, 'String'); get(act_Score2, 'String')};
        
        


        closereq;
    end

    function leftCheckCallback(source, ~, wrs_ListLabelL, wrs_ListDropdownL,...
            wrs_ListNumLabelL,wrs_ListNumEntryL, wrs_NumCorrectLabelL, ...
            wrs_NumCorrectEntryL, wrs_TotalWordsLabelL, wrs_TotalDropdownL,...
            wrs_LevelLabelL, wrs_LevelEntryL, wrs_MaskingLabelL,  wrs_MaskingEntryL)
        if source.Value == 0
            set(wrs_ListLabelL, 'Enable', 'off', 'ForegroundColor', [0.5 0.5 0.5]);
            set(wrs_ListDropdownL, 'Enable', 'off', 'BackgroundColor', [0.8 0.8 0.8]);
            set(wrs_ListNumLabelL, 'Enable', 'off', 'ForegroundColor', [0.5 0.5 0.5]);
            set(wrs_ListNumEntryL, 'Enable', 'off', 'BackgroundColor', [0.8 0.8 0.8]);
            set(wrs_NumCorrectLabelL, 'Enable', 'off', 'ForegroundColor', [0.5 0.5 0.5]);
            set(wrs_NumCorrectEntryL, 'Enable', 'off', 'BackgroundColor', [0.8 0.8 0.8]);
            set(wrs_TotalWordsLabelL, 'Enable', 'off', 'ForegroundColor', [0.5 0.5 0.5]);
            set(wrs_TotalDropdownL, 'Enable', 'off', 'BackgroundColor', [0.8 0.8 0.8]);
            set(wrs_LevelLabelL, 'Enable', 'off', 'ForegroundColor', [0.5 0.5 0.5]);
            set(wrs_LevelEntryL, 'Enable', 'off', 'BackgroundColor', [0.8 0.8 0.8]);
            set(wrs_MaskingLabelL, 'Enable', 'off', 'ForegroundColor', [0.5 0.5 0.5]);
            set(wrs_MaskingEntryL, 'Enable', 'off', 'BackgroundColor', [0.8 0.8 0.8]);

        else
            set(wrs_ListLabelL, 'Enable', 'on', 'ForegroundColor', [ 0 0 0 ]);
            set(wrs_ListDropdownL, 'Enable', 'on', 'BackgroundColor', [1 1 1]);
            set(wrs_ListNumLabelL, 'Enable', 'on', 'ForegroundColor', [ 0 0 0 ]);
            set(wrs_ListNumEntryL, 'Enable', 'on', 'BackgroundColor', [1 1 1]);
            set(wrs_NumCorrectLabelL, 'Enable', 'on', 'ForegroundColor', [ 0 0 0 ]);
            set(wrs_NumCorrectEntryL, 'Enable', 'on', 'BackgroundColor', [1 1 1]);
            set(wrs_TotalWordsLabelL, 'Enable', 'on', 'ForegroundColor', [ 0 0 0 ]);
            set(wrs_TotalDropdownL, 'Enable', 'on', 'BackgroundColor', [1 1 1]);
            set(wrs_LevelLabelL, 'Enable', 'on', 'ForegroundColor', [0 0 0]);
            set(wrs_LevelEntryL, 'Enable', 'on', 'BackgroundColor', [1 1 1]);
            set(wrs_MaskingLabelL, 'Enable', 'on', 'ForegroundColor', [0 0 0]);
            set(wrs_MaskingEntryL, 'Enable', 'on', 'BackgroundColor', [1 1 1]);
        end
    end

    function rightCheckCallback(source, ~, wrs_ListLabelR, wrs_ListDropdownR,...
            wrs_ListNumLabelR,wrs_ListNumEntryR, wrs_NumCorrectLabelR, ...
            wrs_NumCorrectEntryR, wrs_TotalWordsLabelR, wrs_TotalDropdownR, ...
            wrs_LevelLabelR, wrs_LevelEntryR, wrs_MaskingLabelR, wrs_MaskingEntryR)
        if source.Value == 0
            set(wrs_ListLabelR, 'Enable', 'off', 'ForegroundColor', [0.5 0.5 0.5]);
            set(wrs_ListDropdownR, 'Enable', 'off', 'BackgroundColor', [0.8 0.8 0.8]);
            set(wrs_ListNumLabelR, 'Enable', 'off', 'ForegroundColor', [0.5 0.5 0.5]);
            set(wrs_ListNumEntryR, 'Enable', 'off', 'BackgroundColor', [0.8 0.8 0.8]);
            set(wrs_NumCorrectLabelR, 'Enable', 'off', 'ForegroundColor', [0.5 0.5 0.5]);
            set(wrs_NumCorrectEntryR, 'Enable', 'off', 'BackgroundColor', [0.8 0.8 0.8]);
            set(wrs_TotalWordsLabelR, 'Enable', 'off', 'ForegroundColor', [0.5 0.5 0.5]);
            set(wrs_TotalDropdownR, 'Enable', 'off', 'BackgroundColor', [0.8 0.8 0.8]);
            set(wrs_LevelLabelR, 'Enable', 'off', 'ForegroundColor', [0.5 0.5 0.5]);
            set(wrs_LevelEntryR, 'Enable', 'off', 'BackgroundColor', [0.8 0.8 0.8]);
            set(wrs_MaskingLabelR, 'Enable', 'off', 'ForegroundColor', [0.5 0.5 0.5]);
            set(wrs_MaskingEntryR, 'Enable', 'off', 'BackgroundColor', [0.8 0.8 0.8]);

        else
            set(wrs_ListLabelR, 'Enable', 'on', 'ForegroundColor', [ 0 0 0 ]);
            set(wrs_ListDropdownR, 'Enable', 'on', 'BackgroundColor', [1 1 1]);
            set(wrs_ListNumLabelR, 'Enable', 'on', 'ForegroundColor', [ 0 0 0 ]);
            set(wrs_ListNumEntryR, 'Enable', 'on', 'BackgroundColor', [1 1 1]);
            set(wrs_NumCorrectLabelR, 'Enable', 'on', 'ForegroundColor', [ 0 0 0 ]);
            set(wrs_NumCorrectEntryR, 'Enable', 'on', 'BackgroundColor', [1 1 1]);
            set(wrs_TotalWordsLabelR, 'Enable', 'on', 'ForegroundColor', [ 0 0 0 ]);
            set(wrs_TotalDropdownR, 'Enable', 'on', 'BackgroundColor', [1 1 1]);
            set(wrs_LevelLabelR, 'Enable', 'on', 'ForegroundColor', [0 0 0]);
            set(wrs_LevelEntryR, 'Enable', 'on', 'BackgroundColor', [1 1 1]);
            set(wrs_MaskingLabelR, 'Enable', 'on', 'ForegroundColor', [0 0 0]);
            set(wrs_MaskingEntryR, 'Enable', 'on', 'BackgroundColor', [1 1 1]);
        end
    end

end