classdef WBTreflexFSM < handle
    properties(Access = protected)
        isRunning = 0;
        pressure;
        DoneMeasuring;
        
        tolerance = 10;  % set tolerance to 10 daPa
        target_p = 0;    % set target pressure to 0 daPa
        
        level_idx;
        N_levels;
    end
    
    %% abstract methods
    methods (Abstract)
        SetPressure(self, target_p, pump_speed, tolerance )
        MeasureReflexAbsorbance(self, level_idx)
        StopStimulation(self)
    end
    
    %% public methods
    methods
        function reflex = Run(self)
            self.isRunning = 1;
            self.DoneMeasuring = 0;
            while (self.isRunning)
                if ~exist('state')
                    state = 0;
                end
                %% Absorbance state machine
                switch state
                    case {0}
                        % Equalize pressure
                        self.SetPressure( self.target_p, 300, self.tolerance );
                        state = 1;
                    case {1}
                        % Measure reflex absorbance when pressure ok
                        %  - Reject noisy ones
                        if ( le( abs(self.pressure - self.target_p), self.tolerance ) )
                            reflex(:,self.level_idx) = self.MeasureReflexAbsorbance(self.level_idx);
                            if eq( self.level_idx, self.N_levels )
                                state = 2;
                            else
                                self.level_idx = self.level_idx + 1;
                                state = 0;
                            end
                        end
                    case {2}
                        % Stop stimulation
                        %self.StopStimulation();
                        self.isRunning = 0;
                end
                pause(0.01)
            end
        end
    end
end