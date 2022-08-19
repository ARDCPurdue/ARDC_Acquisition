classdef WBT < handle
    properties(Access = private)
        resp_idx;
        N_tubes = 4;
        N_resp = 32;
        N_abs_resp = 32;
        status = 0;
        
        blk_len = 1024;
        
        %Undefined?
        cal_lev_data;
        cal_data;
        %%%%%%%%%%%%
        
        idx_lo = 12;
        idx_hi = 374;
        output_voltage_at_100dB = 345;
        output_voltage_at_96dB = 218;
    end
    
    properties(Access = public)
    fs = 22050;
    end
    
    %% public methods
    methods
        function N_tubes = GetN_tubes(self)
            N_tubes = self.N_tubes;
        end
        
        function stim = GenStim( self, mode )
            load wbt_click_rotatet_396_indexs_left.dat
            wbt_click_rotatet_396_indexs_left = wbt_click_rotatet_396_indexs_left(:);
            click = circshift(wbt_click_rotatet_396_indexs_left ./ max(abs(wbt_click_rotatet_396_indexs_left)),[-625,0]);
            
            % load calibration
            if strcmp( mode, 'adult' )
                stim = self.cal_lev_data.calLevAdult*click;
            elseif strcmp( mode, 'infant' )
                stim = self.cal_lev_data.calLevInfant*click;
            end
        end
        
        function Zc = GetZc(self, cal_type)
            % Z0    Characteristic impedance [1.2*343/(a^2*pi)]
            if strcmp(cal_type, 'adult')
                radius = 0.00375;
            elseif strcmp(cal_type, 'infant')
                radius = 0.00235;
            else
                error('Error in Zc - undefined age setting')
            end
            
            Zc = 1.2*343/(radius^2*pi);
        end
        
        function DoCalibration( self, data, cal_type )
            %            Input:
            % data       probe pressures
            % freq       frequencies
            % pressure   atmospheric pressure
            % temp       temperature
            % plot_bool  plot calibration
            disp('Doing calibration...')
            freq = 0:(self.fs/self.blk_len):(self.fs/2-self.fs/2/self.blk_len);
            pressure = 101325;
            temp = 22;
            plot_bool = 1;
            self.cal_data.data_fft = fft(data);
            
            [self.cal_data.Ps,...
                self.cal_data.Zs, ...
                self.cal_data.Zref, ...
                self.cal_data.Zest, ...
                self.cal_data.error, ...
                self.cal_data.rho, ...
                self.cal_data.c] = WBTCal(self.cal_data.data_fft(1:end/2,:).',freq,temp,pressure,plot_bool);
            
            
            Zc = self.GetZc(cal_type);
            [self.cal_data.q0,self.cal_data.R0] = self.PsZs_to_R0q0( self.cal_data.Ps, self.cal_data.Zs, Zc );
        end
        
        function [q0,R0]=PsZs_to_R0q0(self, Ps,Zs,Zc)
            % Convert Thevenin source parameter to reflectance source parameters
            %   [q0,R0]=PsZs_to_R0q0(Ps,Zs,Z0)
            % q0    Source indident response
            % R0    Source reflectance
            % Ps    Thevenin source pressure
            % Zs    Thevenin source impedance
            % Z0    Characteristic impedance [1.2*343/(a^2*pi)]
            
            q0=Ps.*Zc./(Zs+Zc);                       
            R0=(Zs-Zc)./(Zs+Zc);
        end
        
        function RejectNoise(self, data_obj)
            % 'do rejection and remove faulty responses'
        end
        
        function status = TubeDone(self, data_obj)
            status = 0;
            if ge(size(data_obj.GetResponseMat,2), self.N_resp )
                status = 1;
            end
        end
        
        function status = EarDone(self, data_obj)
            status = 0;
            if ge(size(data_obj.GetResponseMat,2), self.N_abs_resp )
                status = 1;
            end
        end
        
        function output = GetCalibrationData(self)
           output = self.cal_data; 
        end
        
        function SetLevelCalibration(self, data)
            self.cal_lev_data = data;
        end
        
        function SetCalibrationData(self, data)
           self.cal_data = data; 
        end
        
        function cal_type = GetCalType(self)
            cal_type = self.cal_data.cal_type;
        end
        
        function [idx_lo, idx_hi] = GetIndices(self)
            idx_lo = self.idx_lo;
            idx_hi = self.idx_hi;
        end
        
        function absorbance = GetAbsorbance(self, input)
            % Calculate power absorbance
            impedance = self.impedance_engine(input);
            reflectance = self.reflectance_engine(impedance);
            absorbance = 1 - reflectance .* conj(reflectance);
        end
           
        function reflectance = reflectance_engine(self, impedance)
            % Calculate complex reflectance
            Zc = self.GetZc(self.cal_data.cal_type);
            reflectance = (impedance-Zc) ./ (impedance+Zc);
        end
            
        function impedance = impedance_engine(self, input)
            % Calculate complex impedance
            input = input(:);
            input_fft = fft(input).';
            impedance = self.cal_data.Zs .* input_fft(1:end/2) ./ (self.cal_data.Ps - input_fft(1:end/2));
        end
    end
end


