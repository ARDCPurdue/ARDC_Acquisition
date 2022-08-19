classdef WBTabsFSM < handle
    properties(Access = protected)
        isRunning = 0;
        pressure;
        DoneMeasuring;
        
        tolerance = 10;  % set tolerance to 10 daPa
        target_p = 0;    % set target pressure to 0 daPa
    end
    
    %% abstract methods
    methods (Abstract)
        SetPressure(self, target_p, pump_speed, tolerance )
        StartStimulation(self)
        MeasureAbsorbance(self)
        StopStimulation(self)
    end
    
    %% public methods
    methods
        function absorbance = Run(self)
            self.isRunning = 1;
            self.DoneMeasuring = 0;
            while (self.isRunning)
                if ~exist('state')
                    state = 0;
                end
                %% Absorbance state machine
                switch state
                    case {0}
                        % idle state
                        self.StartStimulation();
                        state = 1;
                    case {1}
                        % Equalize pressure
                        self.SetPressure( 0, 300, self.tolerance );
                        state = 2;
                    case {2}
                        % Measure absorbance when pressure ok
                        %  - Reject noisy ones
                        if ( le( abs(self.pressure - self.target_p), self.tolerance ) )
                            absorbance = self.MeasureAbsorbance();
                            state = 3;
                        end
                    case {3}
                        % Stop stimulation
                        self.StopStimulation();
                        self.isRunning = 0;
                end
                pause(0.01)
            end
        end
    end
end