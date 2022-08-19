classdef WBT3DTTest < TympFSM
    properties(Access = public)
        idx_comp;
        tymp_abs = [];
        tymp_pressure = [];
        wbt;
        
        idx_lo;
        idx_hi;
        freq;
        
        h1;
        f1;
        
        i3;
        conf;
        
        lh event.listener;
    end
    
    %% public methods
    methods
        
        %% Constructor
        function self = WBT3DTTest(cal_type)
            % construct superclass
            self@TympFSM();
            
            % instantiate objects
            self.i3 = I3('Titan');
            self.wbt = WBT();
            
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
            [self.idx_lo, self.idx_hi] = self.wbt.GetIndices();
            
            % setup and do tymp plot
            self.f1=figure('name','tympPlot');
            %             self.h1 = surf(0,0,0);
            %             grid on
            
            self.idx_comp = 1;
            self.tymp_abs = [];
            self.tymp_pressure = [];
        end
        
        function SetPressure(self, target_p, pump_speed, tolerance )
            self.i3.instrument.SetPressure( target_p, pump_speed, tolerance )
        end
        
        function LogPressure(self, src, data)
            self.pressure = data.data;
        end
        
        function LogResponse(self, src, data)
            self.wbt.RejectNoise(data.data);
            absorbance = self.wbt.GetAbsorbance(data.data);
            self.tymp_abs(self.idx_comp,:) = absorbance(self.idx_lo:self.idx_hi);
            self.tymp_pressure(self.idx_comp) = self.pressure;
            %             figure(self.f1)
            %             surf(self.freq, self.tymp_pressure, self.tymp_abs)
            self.idx_comp = self.idx_comp + 1;
        end
        
        function StartStimulation(self)
            % setup stimulus defined in WBT class
            cal_type = self.wbt.GetCalType();
            stim = self.wbt.GenStim( cal_type );
            self.i3.instrument.SetStimuli( stim, 2 );
            self.conf.input.blockLength = size(stim,1);
            
            self.freq = ((self.idx_lo:self.idx_hi)-1).*(self.conf.system.fs.double/double(self.conf.input.blockLength));
            self.i3.instrument.Configure(self.conf);
            self.i3.instrument.Run();
        end
        
        function StartPressureReached(self)
            
        end
        
        function data = SweepPressure(self)
            self.lh(2).Enabled = true;
            disp('Acquiring response...')
            data.freq = self.freq;
            data.pressure = self.tymp_pressure;
            data.absorbance = self.tymp_abs;
        end
        
        function post_pressure = StopPressureReached(self)
            % Find frequency indices for 2000 Hz
            [ ~, idx_2k ] = min(abs(self.freq-2000));
            
            % Calculate average absorbance spectrum
            self.data.avg_abs_tymp = mean( self.data.absorbance( :, 1:idx_2k ), 2 );
            
            % Find TPP from averaged absorbance data
            [self.data.abs_at_TPP,TPP_idx] = max(self.data.avg_abs_tymp);
            self.data.TPP = self.data.pressure(TPP_idx);
            post_pressure = self.data.TPP;
        end
        
        function StopStimulation(self)
            self.lh(2).Enabled = false;
            
            % plot 3D landscape
            figure(self.f1)
            surf(log(self.freq), self.tymp_pressure, 100*self.tymp_abs)
            title(['3DT plot - TTP: ',num2str(self.data.TPP),' daPa'])
            g1=gca;
            set(g1,'YDir','reverse')
            g1.XTick = log([250,500,1000,2000,4000,8000]);
            g1.XTickLabel = [{'250'},{'500'},{'1k'},{'2k'},{'4k'},{'8k'}];
            xlabel('Frequency [Hz]')
            ylabel('Pressure [daPa]')
            zlabel('Absorbance [%]')
            axis([log(226) log(8000) -300 200 0 100])
            
            self.i3.instrument.Stop();
            while ( self.i3.instrument.isRunning );
                pause(0.01)
            end;
        end
    end
end
