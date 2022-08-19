classdef WBTcalTest < WBTcalFSM
    properties(Access = private)
        i3;
        wbt;
        tube;
        conf;
        
        lh event.listener;
    end
    
    %% public methods
    methods
        
        %% Constructor
        function self = WBTcalTest(cal_type)
            % construct superclass
            self@WBTcalFSM();
            
            if strcmp(cal_type, 'adult') || strcmp(cal_type, 'infant')
                self.cal_type = cal_type;
            else
                error('Error in calibration - undefined age setting')
            end
            
            % instantiate objects
            self.i3 = I3('Titan');
            self.wbt = WBT();
            % load calibration
            load('calibration_data_clickLevel.mat')
            self.wbt.SetLevelCalibration(calLevData);
            
            self.N_tubes = self.wbt.GetN_tubes();
            for x = 1:self.N_tubes;
                self.tube{x} = Tube();
            end
            
            self.lh(1) = self.i3.instrument.addlistener('Pressure', @self.LogPressure);
            self.lh(2) = self.i3.instrument.addlistener('Response', @self.LogResponse);
            self.lh(2).Enabled = false;
            
            self.conf = Titan.Conf.Data();
            self.conf.input.blockLength = 1024;
            self.i3.instrument.Configure(self.conf);
        end
        
        function SetPressure(self, target_p, pump_speed, tolerance )
            self.i3.instrument.SetPressure( target_p, pump_speed, tolerance )
        end
        
        function LogPressure(self, src, data)
            self.pressure = data.data;
        end
        
        function LogResponse(self, src, data)
            self.tube{self.tube_idx}.SetResponse(data.data);
            self.wbt.RejectNoise(self.tube{self.tube_idx});
        end
        
        function StartStimulation(self)
            % setup stimulus defined in WBT class
            stim = self.wbt.GenStim( self.cal_type );
            self.i3.instrument.SetStimuli( stim, 2 );
            self.conf.input.blockLength = size(stim,1);
            self.i3.instrument.Configure(self.conf);
            self.i3.instrument.Run();
            disp(' ')
            disp([' Starting ',self.cal_type, ' calibration...'])
            disp(' ')
        end
        
        function AcquireTubeResponse(self)
            self.lh(2).Enabled = true;
            while ~self.wbt.TubeDone(self.tube{self.tube_idx})
                pause(0.25);
            end
            self.lh(2).Enabled = false;
        end
        
        function success = Calibrate(self)
            for x=1:self.N_tubes
                responses(:,x) = self.tube{x}.GetAverage;
            end
            self.wbt.DoCalibration(responses, self.cal_type);
            caldata = self.wbt.GetCalibrationData();
            caldata.cal_type = self.cal_type;
            caldata.time = clock;
            maxlimit = line([226 8000],[0.1 0.1]);
            maxlimit.Color = 'black';
            maxlimit.LineStyle = '--';
            maxlimit.LineWidth = 2
            str_name = ['calibration_data_', caldata.cal_type, '.mat'];
            disp(['saving calibration data to "', str_name, '"'])
            save(str_name,'caldata')
        end
        
        function StopStimulation(self)
            self.i3.instrument.Stop();
            while ( self.i3.instrument.isRunning ); 
                pause(0.01)
            end;
        end
        
    end
end
