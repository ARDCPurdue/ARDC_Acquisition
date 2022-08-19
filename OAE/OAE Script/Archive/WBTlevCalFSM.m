classdef WBTlevCalFSM < handle
    properties(Access = public)
        isRunning = 0;
        pressure;
        tolerance = 10;  % set tolerance to 10 daPa
        target_p = 0;    % set target pressure to 0 daPa
        defalutLevelValue = 300;
        levelToBeSaved;
    end
    
    %% abstract methods
    methods (Abstract)
        SetPressure(self, target_p, pump_speed, tolerance )
        StartStimulation(self, output_voltage)
        SetStimuli(self, freq, level)
        %         AcquireTubeResponse(self)
        %         Calibrate(self)
        StopStimulation(self)
        
        
    end
    
    %% public methods
    methods
        
        
        function Run(self)
            self.isRunning = 1;
            
            while (self.isRunning)
                if ~exist('state')
                    state = 0;
                    %                     self.tube_idx = 1;
                end
                %% WBT cal state machine
                switch state
                    case {0}
                        % idle state%
                        state = 1;
                    case {1}
                        % Prompt user to insert probe in 711 coupler
                        disp('Insert probe in 711 coupler & press any key to continue')
                        pause;
                        
                        self.SetStimuli(1000, self.defalutLevelValue);
                        self.SetPressure( 0, 100, self.tolerance);
                        state = 2;
                    case {2}
                        if ( le( abs(self.pressure - self.target_p), self.tolerance ) )
                            %
                            clc
                            disp('Adjust the 1000 Hz level to 100dB spl');
                            disp('Notice the vpp on the oscilloscope ');
                            disp(' ');
                            disp(['Current level ' num2str(self.defalutLevelValue)])
                            disp('Enter new level or enter 0 when level is ok');
                            prompt = (' ');
                            x = input(prompt);
                            
                            while( x ~= 0)
                                self.StopStimulation();
                                self.SetStimuli(1000, x);
                                clc
                                disp('Adjust the 1000 Hz level to 100dB ');
                                disp('Notice the vpp on the oscilloscope ');
                                disp(' ');
                                disp(['Current level ' num2str(x)])
                                disp('Enter new level or enter 0 when level is ok');
                                prompt = (' ');
                                x = input(prompt);
                            end
                            clc
                            state = 3;
                        end
                        
                    case {3}
                        self.StopStimulation();
                        x = self.defalutLevelValue;
                        self.StartStimulation(x);
                        
                        disp('Adjust the click level to vpp noticed before ');
                        disp(' ');
                        disp(['Current level ' num2str(x)])
                        disp('Enter new level or enter 0 when level is ok');
                        prompt = (' ');
                        
                        x = input(prompt);
                        if x ~= 0
                            self.levelToBeSaved = x;
                        end
                        while( x ~= 0)
                            self.StopStimulation();
                            self.StartStimulation(x);
                            clc
                            disp('Adjust the click level to vpp noticed before ');
                            disp(' ');
                            disp(['Current level ' num2str(x)])
                            disp('Enter new level or enter 0 when level is ok');
                            prompt = (' ');
                            
                            x = input(prompt);
                            if x ~= 0
                                self.levelToBeSaved = x;
                            end
                        end
                        
                        prompt = 'Do you want to save to file? Y/N [Y]: ';
                        str = input(prompt,'s');
                        if isempty(str)
                            str = 'Y';
                            disp('Level calibration discraded');
                        end
                        
                        if str == 'Y'
                            self.Save_Calibration(self.levelToBeSaved);
                            disp('Level calibration saved');
                        end
                        
                        state = 4;
                        
                    case {4}
                        
                        
                        % Do calibration (class)
                        self.StopStimulation();
                        self.isRunning = 0;
                end
                pause(0.01)
            end
        end
    end
end