classdef WBTcalFSM < handle
    properties(Access = protected)
        N_tubes;    % Number of required tube responses
        tube_idx;
        isRunning = 0;
        pressure;
        cal_type;
        
        tolerance = 10;  % set tolerance to 10 daPa
        target_p = 0;    % set target pressure to 0 daPa
    end
    
    %% abstract methods
    methods (Abstract)
        SetPressure(self, target_p, pump_speed, tolerance )
        StartStimulation(self)
        AcquireTubeResponse(self)
        Calibrate(self)
        StopStimulation(self)
    end
    
    %% public methods
    methods
        function Run(self)
            self.isRunning = 1;
            while (self.isRunning)
                if ~exist('state')
                    state = 0;
                    self.tube_idx = 1;
                end
                %% WBT cal state machine
                switch state
                    case {0}
                        % idle state
                        self.StartStimulation();
                        state = 1;
                    case {1}
                        % Prompt user to insert probe in tube x
                        disp(['Insert probe in tube ',num2str(self.tube_idx), ', press any key to continue'])
                        pause;
                        self.SetPressure( 0, 300, self.tolerance );
                        state = 2;
                    case {2}
                        % Acquire N good responses
                        %  - Reject noise ones
                        %  - average when done
                        if ( le( abs(self.pressure - self.target_p), self.tolerance ) )
                            self.AcquireTubeResponse();
                            if eq( self.tube_idx, self.N_tubes )
                                state = 3;
                            else
                                self.tube_idx = self.tube_idx + 1;
                                state = 1;
                            end
                        end
                    case {3}
                        % Do calibration (class)
                        self.Calibrate()
                        self.StopStimulation();
                        self.isRunning = 0;
                end
                pause(0.01)
            end
        end
    end
end