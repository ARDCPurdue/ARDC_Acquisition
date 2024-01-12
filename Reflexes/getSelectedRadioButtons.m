function getSelectedRadioButtons

%Hacky, generally try to avoid global variables...just trying to make a
%quick gui - AS

global output_reflex

% Create the main figure
fig = figure('Name', 'Enter Reflex Results', 'NumberTitle', 'off', 'Position', [100, 100, 1100, 800],'Units','Normalized');

% Define frequencies and levels
frequencies = {'.5', '1', '2', '4'};
levels = {'70', '75', '80', '85', '90', '95', '100', '105','110','115', 'CNT', 'NR'};
conditions = {'Right Contra', 'Left Contra', 'Right Ipsi', 'Left Ipsi'}; 

% Create column headers
x_mg = 150; 
y_mg = 200;
width_mg = 320;
height_mg = 20;
xoffset_mg = 500;
yoffset_mg = 2*y_mg;

colHeader_RC = uicontrol('Style', 'text', 'String', conditions{1}, 'Position', [x_mg, y_mg, width_mg, height_mg], 'HorizontalAlignment', 'center');
colHeader_LC = uicontrol('Style', 'text', 'String', conditions{2}, 'Position', [x_mg+xoffset_mg, y_mg, width_mg, height_mg], 'HorizontalAlignment', 'center');
colHeader_RI = uicontrol('Style', 'text', 'String', conditions{3}, 'Position', [x_mg, y_mg+yoffset_mg, width_mg, height_mg], 'HorizontalAlignment', 'center');
colHeader_LI = uicontrol('Style', 'text', 'String', conditions{4}, 'Position', [x_mg+xoffset_mg, y_mg+yoffset_mg, width_mg, height_mg], 'HorizontalAlignment', 'center');

offs = [0,0;1,0;0,1;1,1];

for g = 1:4
    for j = 1:numel(levels)
        x = (j - 1) * 40 + 90;
        x = x+offs(g,1)*xoffset_mg;
        y = 180+offs(g,2)*yoffset_mg;
        uicontrol('Style', 'text', 'String', levels{j}, 'Position', [x, y, 40, 20], 'HorizontalAlignment', 'left');
    end
end

% Create a matrix to store radio button handles
radioHandles = zeros(numel(frequencies), numel(levels), 4);

% Initialize a matrix to store selected states
selectedMatrix = zeros(numel(frequencies), numel(levels), 4);

% Create row headers and radio buttons
for g2 = 1:4
    for i = 1:numel(frequencies)
        y = (numel(frequencies) - i) * 30 + 60;
        y = y+offs(g2,2)*yoffset_mg;
        % Create row label
        uicontrol('Style', 'text', 'String', frequencies{i}, 'Position', [10, y, 30, 20], 'HorizontalAlignment', 'center');
        
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
updateButton = uicontrol('Style', 'pushbutton', 'String', 'Update Matrix', 'Position', [200, 20, 100, 30], 'Callback', @(~, ~) updateAndPrint(levels),'Enable',buttonStatus);

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
            case 0
                buttonStatus = 'off';
        end
        updateButton = uicontrol('Style', 'pushbutton', 'String', 'Update Matrix', 'Position', [200, 20, 100, 30], 'Callback', @(~, ~) updateAndPrint(levels),'Enable',buttonStatus);
    end

% Function to update and print the matrix
    function updateAndPrint(levels)
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
        
        closereq; 
    end

end