classdef WBTlevCalTest < WBTlevCalFSM
    properties(Access = private)
        i3;
        wbt;        
        conf;        
        lh event.listener;
    end
    
    %% public methods
    methods
        
        %% Constructor
        function self = WBTlevCalTest(cal_type)
            % construct superclass
            self@WBTlevCalFSM();
            
%             if strcmp(cal_type, 'adult') || strcmp(cal_type, 'infant')
%                 self.cal_type = cal_type;
%             else
%                 error('Error in calibration - undefined age setting')
%             end
            
            % instantiate objects
            self.i3 = I3('Titan');
            self.wbt = WBT();
            
            self.pressure=[];

            
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
        
        function StartStimulation(self, output_voltage)
            % setup stimulus defined in WBT class                              
            load wbt_click_rotatet_396_indexs_left.dat
            wbt_click_rotatet_396_indexs_left = wbt_click_rotatet_396_indexs_left(:);
            click = circshift(wbt_click_rotatet_396_indexs_left ./ max(abs(wbt_click_rotatet_396_indexs_left)),[-625,0]);
            stim = output_voltage*click;                        
            self.i3.instrument.SetStimuli( stim, 2 );
            self.conf.input.blockLength = size(stim,1);
            self.i3.instrument.Configure(self.conf);
            self.i3.instrument.Run();

        end                
        
                % Set stimuli - find frequency bin closest to 1000 Hz
        function SetStimuli( self, freq, level)
            
            blk_len = 617;
            bin_f = round(freq/(self.wbt.fs/blk_len));
            stim = level*sin(2*pi*bin_f*(self.wbt.fs/blk_len)*1/self.wbt.fs*(0:(blk_len-1))).';            
            self.i3.instrument.SetStimuli( stim, 2 );
            self.conf.input.blockLength = size(stim,1);
            self.i3.instrument.Configure(self.conf);
            self.i3.instrument.Run();
        end;
        
        function StopStimulation(self)
            self.i3.instrument.Stop();
            while ( self.i3.instrument.isRunning ); 
                pause(0.01)
            end;
        end
        
        function Save_Calibration(self, output_voltage_at_100dB)
            
            calLevData.calLevAdult = output_voltage_at_100dB;
            calLevData.calLevInfant = output_voltage_at_100dB-150;%aprox -4dB
            calLevData.time = clock;
            str_name = ['calibration_data_clickLevel.mat'];
            disp(['saving calibration data to "', str_name, '"'])
            save(str_name,'calLevData')
        end
        
    end
end
