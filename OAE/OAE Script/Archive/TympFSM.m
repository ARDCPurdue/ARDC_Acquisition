classdef TympFSM < handle
    properties(Access = protected)
        pressure;
        isRunning = 0;
        start_pressure;
        stop_pressure;
        post_pressure;
        tolerance;
        sweep_speed;
        data;
    end
    
    %% abstract methods
    methods (Abstract)
        SetPressure(self, target_p, pump_speed, tolerance )
        StartStimulation(self)
        StartPressureReached(self)
        SweepPressure(self)
        StopStimulation(self)
    end
    
    %% public methods
    methods
        function Config(self, start_pressure, stop_pressure, tolerance, sweep_speed)
            self.start_pressure = start_pressure;
            self.stop_pressure = stop_pressure;
            self.tolerance = tolerance;
            self.sweep_speed = sweep_speed;
        end
        
        function data = Run(self)
            self.isRunning = 1;
            while (self.isRunning)
                if ~exist('state')
                    state = -1;
                end
                %% Tymp state machine
                switch state
                    case {-1}
                        self.StartStimulation();
                        state = 0;
                        
                    case {0}
                        % Pump to start pressure
                        self.SetPressure( self.start_pressure, 300, self.tolerance );
                        state = 1;
                    case {1}
                        % When start pressure reached - sweep to stop pressure and plot ear volume
                        if ( le( abs(self.pressure - self.start_pressure), self.tolerance ) )
                            self.SetPressure( self.stop_pressure, self.sweep_speed, self.tolerance );
                            self.StartPressureReached();
                            state = 2;
                        end
                    case {2}
                        % During sweep to stop pressure - plot tympanogram
                        self.data = self.SweepPressure();
                        
                        % When stop pressure reached - pump to TPP pressure
                        if ( le( abs(self.pressure - self.stop_pressure), self.tolerance ) )
                            self.post_pressure = self.StopPressureReached();
                            state = 3;
                        end
                    case {3}
                        self.SetPressure( self.post_pressure, 300, self.tolerance );
                        state = 4;
                    case {4}
                        % When ambient pressure reached - stop stimulating
                        if ( le( abs(self.pressure - self.post_pressure), self.tolerance ) )
                            state = 0;
                            self.isRunning = 0;
                            self.StopStimulation();
                        end
                end
                pause(0.01)
            end
            data = self.data;
        end
    end
end