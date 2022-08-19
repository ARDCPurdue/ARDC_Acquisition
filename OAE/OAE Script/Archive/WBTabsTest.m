classdef WBTabsTest < WBTabsFSM
    properties(Access = protected)
        i3;
        wbt;
        ear;
        conf;
        
        lh event.listener;
    end
    
    %% public methods
    methods
        
        %% Constructor
        function self = WBTabsTest(cal_type)
            % construct superclass
            self@WBTabsFSM();
            
            % instantiate objects
            self.i3 = I3('Titan');
            self.wbt = WBT();
            self.ear = Tube();
            
            self.lh(1) = self.i3.instrument.addlistener('Pressure', @self.LogPressure);
            self.lh(2) = self.i3.instrument.addlistener('Response', @self.LogResponse);
            self.lh(2).Enabled = false;
            
            self.conf = Titan.Conf.Data();
            self.i3.instrument.Configure(self.conf);
            
            % load calibration
            load('calibration_data_clickLevel.mat')
            self.wbt.SetLevelCalibration(calLevData);
            
            str_name = ['calibration_data_', cal_type, '.mat'];
            load(str_name)
            self.wbt.SetCalibrationData(caldata);
        end
        
        function SetPressure(self, target_p, pump_speed, tolerance )
            self.i3.instrument.SetPressure( target_p, pump_speed, tolerance )
        end
        
        function LogPressure(self, src, data)
            self.pressure = data.data;
        end
        
        function LogResponse(self, src, data)
            self.ear.SetResponse(data.data);
            self.wbt.RejectNoise(self.ear);
        end
        
        function StartStimulation(self)
            % setup stimulus defined in WBT class
            cal_type = self.wbt.GetCalType();
            stim = self.wbt.GenStim( cal_type );
            self.i3.instrument.SetStimuli( stim, 2 );
            self.conf.input.blockLength = size(stim,1);
            self.i3.instrument.Configure(self.conf);
            self.i3.instrument.Run();
        end
        
        function absorbance = MeasureAbsorbance(self)
            self.lh(2).Enabled = true;
            disp('Acquiring response...')
            while ~self.wbt.EarDone(self.ear)
                pause(0.25);
            end
            self.lh(2).Enabled = false;
            
            % Calc Absorbance
            [idx_lo, idx_hi] = self.wbt.GetIndices();
            absorbance = self.wbt.GetAbsorbance( self.ear.GetAverage() );
            % Plot
            figure
            freq = ((idx_lo:idx_hi)-1)*(22050/1024);
            semilogx( freq, absorbance(idx_lo:idx_hi) )
            axis([freq(1) freq(end) 0 1])
            a=gca;
            a.XTick = [250,500,1000,2000,4000,8000];
            a.XTickLabel = [{'250'},{'500'},{'1000'},{'2000'},{'4000'},{'8000'}];
            
        end
        
        function StopStimulation(self)
            self.i3.instrument.Stop();
            while ( self.i3.instrument.isRunning ); 
                pause(0.01)
            end;
        end
        
    end
end
