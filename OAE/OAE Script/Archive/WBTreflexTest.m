classdef WBTreflexTest < WBTreflexFSM
    properties(Access = private)
        i3;
        wbt;
        
        conf;
        cal;
        cal_type;
        activator_levels_dB_SPL;
        transducer_type;
        
        sin_freq;
        N_D_blks;
        N_seqs;
        N_D_total;
        blk_idx;
        
        SequenceRunning;
        response;
        
        lh event.listener;
        
        % defines
        D = 1024;
        d = 512;
    end
    
    %% public methods
    methods
        
        %% Constructor
        function self = WBTreflexTest(cal_type, activator_levels_dB_SPL, sin_freq, target_p, transducer_type)
            % construct superclass
            self@WBTreflexFSM();
            
            if strcmp(cal_type, 'adult') || strcmp(cal_type, 'infant')
                self.cal_type = cal_type;
            else
                error('Error in calibration - undefined age setting')
            end
            
            self.activator_levels_dB_SPL = activator_levels_dB_SPL;
            self.level_idx=1;
            self.N_levels = length(activator_levels_dB_SPL);
            self.sin_freq = sin_freq;
            self.target_p = target_p;
            
            self.transducer_type = transducer_type;
            
            if strcmp(transducer_type,'contra')
                load('contra_transducer_level_cal.mat');
            else
                load('transducer_level_cal.mat');
            end
            self.cal = cal;
            
            % instantiate objects
            self.i3 = I3('Titan');
            self.wbt = WBT();
            
            self.lh(1) = self.i3.instrument.addlistener('Pressure', @self.LogPressure);
            self.lh(2) = self.i3.instrument.addlistener('Response', @self.LogResponse);
            self.lh(2).Enabled = false;
            
            self.conf = Titan.Conf.Data();
            self.conf.input.blockLength = 1024;
            if strcmp(transducer_type,'contra')
                self.conf.output.ch1 = Titan.Conf.Output.transducer;
            else
                self.conf.output.ch1 = Titan.Conf.Output.probe;
            end
            self.i3.instrument.Configure(self.conf);
            
            % load WBT calibration
            load('calibration_data_clickLevel.mat')
            self.wbt.SetLevelCalibration(calLevData);
            
            str_name = ['calibration_data_', cal_type, '.mat'];
            load(str_name)
            self.wbt.SetCalibrationData(caldata);
            
            figure
        end
        
        function SetPressure(self, target_p, pump_speed, tolerance )
            % To get pump active, set stim active
            self.i3.instrument.SetStimuli( 0.001*ones(self.conf.input.blockLength,1), 1 );
            self.i3.instrument.Run();
            self.i3.instrument.SetPressure( target_p, pump_speed, tolerance );
            pause(0.1)
            while gt( abs(self.pressure - target_p), tolerance )
                pause(0.1);
            end
            self.StopStimulation();
        end
        
        function LogPressure(self, src, data)
            self.pressure = data.data;
        end
        
        function LogResponse(self, src, data)
            idxs = (1:self.D)+(self.D*self.blk_idx);
            self.response(idxs) = data.data;
            if eq(self.blk_idx, self.N_D_total-1)
                self.SequenceRunning = 0;
            else
                self.blk_idx = self.blk_idx + 1;
            end
        end
        
        function activator = GetActivator( self, sin_freq, level_dB_SPL, N_d )
            % find rms cal value and convert to amplitude (sqrt(2))
            Pa_per_Vp = interp1( self.cal.freq, self.cal.output.speaker_sens_Pa_per_Vp(:,1), sin_freq );
            amplitude = (1000)*10^((level_dB_SPL-94)/20)/Pa_per_Vp;
            sine = amplitude*sin(2*pi*sin_freq*((0:(N_d*self.d-1))*(1/self.conf.system.fs.double()))).';
            env_len = 50;
            envelope = kaiser(2*env_len,7);
            window = [envelope(1:env_len);ones(N_d*self.d-2*env_len,1);envelope((1:env_len)+env_len)];
            activator = ( sine.*window );
        end
        
        function activator = GetActivatorSubblock( self, sin_freq, level_dB_SPL)
            % find rms cal value and convert to amplitude (sqrt(2))
            Pa_per_Vp = interp1( self.cal.freq, self.cal.output.speaker_sens_Pa_per_Vp(:,1), sin_freq );
            amplitude = (1000)*10^((level_dB_SPL-94)/20)/Pa_per_Vp;
            sine = amplitude*sin(2*pi*sin_freq*((0:(5*self.d-1))*(1/self.conf.system.fs.double()))).';
            env_len = 50;
            envelope = kaiser(2*env_len,7);
            window = [envelope(1:env_len);ones(5*self.d-2*env_len,1);envelope((1:env_len)+env_len)];
            activator = ( sine.*window );
        end
        
        function ConstructReflexStim(self, level_idx)
            % Generate the four building blocks 
            % stim, activator, silence size d (512) and D (1024)
            % and concatenate according to Doug Keefe description
            WBTstim = self.wbt.GenStim( self.cal_type );
            
            d = zeros(self.d,1);
            D = zeros(self.D,1);
            
            if strcmp(self.transducer_type,'contra')
                activator = self.GetActivator( self.sin_freq, self.activator_levels_dB_SPL(level_idx), 32 );
                activator_seq = [D; D; D; activator; D; D; D; D; D; D; D; D; D; D; D; D; D; D; D; D ];
            else
                activator = self.GetActivatorSubblock( self.sin_freq, self.activator_levels_dB_SPL(level_idx) );
                activator_seq = [D; D; D; activator; d; D; activator; d; D; activator; d; D; activator; d; D; D; D; D; D; D; D; D; D; D; D; D; D; D; D; D; D ];
            end
            
            stim_seq = [D; D; WBTstim; D; D; D; WBTstim; D; D; D; WBTstim; D; D; D; WBTstim; D; D; D; WBTstim; D; D; D; D; D; D; D; D; D; D; D; D; D; D; D; D ];
            self.N_D_blks = size(activator_seq,1)/self.D;

            total_seq = [activator_seq, stim_seq];

            self.N_seqs = 4;
            self.N_D_blks = self.N_D_blks;
            self.N_D_total = self.N_D_blks * self.N_seqs;
            self.i3.instrument.SetStimuli( total_seq, [1,2] );
            
            % set input blocksize to D
            self.conf.input.blockLength = self.D;
            self.i3.instrument.Configure(self.conf);
            
            self.blk_idx = 0;
        end
        
        function abs_diff = MeasureReflexAbsorbance(self, level_idx)
            self.ConstructReflexStim(level_idx);
            
            self.i3.instrument.Run();
            self.SequenceRunning = 1;
            self.lh(2).Enabled = true;
            
            while self.SequenceRunning
                pause(0.1);
            end
            reflex = self.response;
            self.StopStimulation();
            self.lh(2).Enabled = false;
            
            for x = 1:self.N_seqs
                reflex_mat(:,x) = reflex((1:((self.N_D_blks-3)*self.D))+(self.N_D_blks*self.D)*(x-1));
            end
            reflex = mean(reflex_mat,2);
            abs_baseline = self.wbt.GetAbsorbance( reflex((1:self.D)+self.D*2) );
            abs_contract = self.wbt.GetAbsorbance( reflex((1:self.D)+self.D*18) );
            
            % Calc Absorbance
            [idx_lo, idx_hi] = self.wbt.GetIndices();
            freq = ((idx_lo:idx_hi)-1)*(22050/1024);
            [f_center, idxs_lo] = CalcOctaveIndicesFreqs(freq, 3);
            abs_baseline = CalcOctaveSpectrum(abs_baseline(idx_lo:idx_hi), idxs_lo);
            abs_contract = CalcOctaveSpectrum(abs_contract(idx_lo:idx_hi), idxs_lo);
            abs_diff = abs_contract - abs_baseline;
            
            % Plot
            semilogx( f_center, abs_diff )
            axis([freq(1) freq(end) -0.1 0.1])
            a=gca;
            a.XTick = [250,500,1000,2000,4000,8000];
            a.XTickLabel = [{'250'},{'500'},{'1000'},{'2000'},{'4000'},{'8000'}];
            title(['\Delta absorbance = contracted - baseline. Target pressure: ', num2str(self.target_p), ' daPa'])
            xlabel('Frequency [Hz]')
            ylabel('\Delta Absorbance')
            grid on
            hold on
            for x = 1:level_idx
                txt(x) = {[num2str(self.activator_levels_dB_SPL(x)),' dB SPL']};
            end
            legend(txt)
        end
        
        function StopStimulation(self)
            self.i3.instrument.Stop();
            while ( self.i3.instrument.isRunning ); 
                pause(0.01)
            end;
        end
        
    end
end
