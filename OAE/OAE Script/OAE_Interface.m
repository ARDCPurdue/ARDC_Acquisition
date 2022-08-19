%Class structure created to test out sensors
%Based highly off @HelloWorld.m
%TODO: why does it need < handle?
%Microphone Calibration
%Speaker Calibration

classdef OAE_Interface < handle
    
    properties(Access = private)
        i3;
        conf;
        lh event.listener;
        fs;
        N_trials;
    end
    
    properties(Access = public)
        pressure;
        response;
        IsDone;

    end
    
    methods
        
        function self = OAE_Interface(fsIn)
            self.i3 = I3('Titan'); % instantiate objects
            self.lh(1) = self.i3.instrument.addlistener('Pressure', @self.LogPressure);
            % setup event listner for the mic response log.
            self.lh(2) = self.i3.instrument.addlistener('Response', @self.LogResponse);
            
            %           self.pressure=[];
            self.response=[];
            
            self.conf = Titan.Conf.Data(); %load the configuration
            self.conf.system.fs = ['fs' num2str(fsIn)];
            self.fs = fsIn;
            if(fsIn > 22050)
                self.conf.input.blockLength = 512;
            end
            
            self.i3.instrument.Configure(self.conf); %set the configuration in the device.
        end
        
        
        function SetPressure(self, target_p, pump_speed, tolerance)
            self.i3.instrument.Run();
            self.i3.instrument.SetPressure( target_p, pump_speed, tolerance )
            self.lh(1).Enabled = true; % enable the logging of the pressure.
            pause(1);
            self.i3.instrument.Stop();
            while ( self.i3.instrument.isRunning ) %  wait until the device has stopped.
                pause(0.01)
            end
        end
        
        
        function StartTrial_old(self, f1, f2, amplitude_mV, stimulusLength)
            
            % setup stimulus
            % i3 support only stimulus length > 256, 512 for fs = 44.1kHz
            self.response=[];
            
            T=1/self.fs; % Sampling period
            t = (0:stimulusLength-1)*T;        % Time vector
            freqStepSize = self.fs/stimulusLength;
            bin_f1 = round(f1/(freqStepSize));
            bin_f2 = round(f2/(freqStepSize));
            
            stim1 = amplitude_mV(1)*sin(2*pi*bin_f1*freqStepSize*t).'; % create the stimulus
            stim2 = amplitude_mV(2)*sin(2*pi*bin_f2*freqStepSize*t).'; % create the stimulus
            
            self.i3.instrument.SetStimuli([stim1,stim2], [1 2]); % Set stimulus in the device configuration

            %self.i3.instrument.SetStimuli(stim1, 1);
            
            self.conf.input.blockLength = length(stim1);% update the configuration by changing the block length.
            % block length is the same for stimilus and response
            self.i3.instrument.Configure(self.conf); %set the configuration in the device.
            
            % kick it all off, by set the device to run with the current configuration
            self.i3.instrument.Run(); % run the device with the current configuration
            self.lh(2).Enabled = true; % enable the logging of the mic response.
        end
        
        function StartTrial(self, f1, f2, amplitude_mV, stimulusLength, N_trials)
            
            % setup stimulus
            % i3 support only stimulus length > 256, 512 for fs = 44.1kHz
            self.response=[];
            self.N_trials = N_trials;
            self.IsDone = false;
            
            T=1/self.fs; % Sampling period
            t = (0:stimulusLength-1)*T;        % Time vector
            % Pad by extra 10% of duration (which is T)
            pad = zeros(ceil(self.fs * 0.1 * T), 1);
            rampdur = 0.020;
            ramp = hanning(ceil(self.fs * rampdur));
            stim1 = amplitude_mV(1)*sin(2*pi*f1*t).'; % create the stimulus
            stim1(1:floor(numel(ramp)/2)) = stim1(1:floor(numel(ramp)/2)) .* ramp(1:floor(numel(ramp)/2));
            stim1((end-floor(numel(ramp)/2) + 1):end) = stim1((end-floor(numel(ramp)/2) + 1):end) .* ramp(1:floor(numel(ramp)/2));
            stim2 = amplitude_mV(2)*sin(2*pi*f2*t).'; % create the stimulus
            stim2(1:floor(numel(ramp)/2)) = stim2(1:floor(numel(ramp)/2)) .* ramp(1:floor(numel(ramp)/2));
            stim2((end-floor(numel(ramp)/2) + 1):end) = stim2((end-floor(numel(ramp)/2) + 1):end) .* ramp(1:floor(numel(ramp)/2));
            stim1 = [stim1(:); pad(:)];
            stim2 = [stim2(:); pad(:)];
            
            self.i3.instrument.SetStimuli([stim1,stim2], [1 2]); % Set stimulus in the device configuration
            
            %self.i3.instrument.SetStimuli(stim1, 1);
            
            self.conf.input.blockLength = numel(stim1);% update the configuration by changing the block length.
            % block length is the same for stimilus and response
            self.i3.instrument.Configure(self.conf); %set the configuration in the device.
            
            % kick it all off, by set the device to run with the current configuration
            self.i3.instrument.Run(); % run the device with the current configuration
            self.lh(2).Enabled = true; % enable the logging of the mic response.
        end
        
        %         function ChangeStimulation(self, freq, amplitude_mV, stimulusLength)
        %             self.lh(2).Enabled = false; % disable the logging of the mic response.
        %
        %             % setup stimulus
        %             % i3 support only stimulus length > 256
        %
        %             T=1/self.fs; % Sampling period
        %             t = (0:stimulusLength-1)*T;        % Time vector
        %             freqStepSize = self.fs/stimulusLength;
        %             bin_f = round(freq/(freqStepSize));
        %
        %             stim = amplitude_mV*sin(2*pi*bin_f*freqStepSize*t).'; % create the stimulus
        %             self.i3.instrument.SetStimuli( stim, 2 ); % Set stimulus in the device configuration
        %
        %             self.conf.input.blockLength = size(stim,1);% update the configuration by changing the block length.
        %                                                        % block length is the same for stimilus and response
        %
        %             self.i3.instrument.Configure(self.conf); %set the configuration in the device.
        %
        %             % kick it all off, by set the device to run with the current configuration
        %             self.i3.instrument.Update(); % update the device with the current configuration
        %             self.lh(2).Enabled = true; % enable the logging of the mic response.
        %         end
        
        function StopTrial(self)
            self.i3.instrument.Stop(); % Set the device to stop
            while ( self.i3.instrument.isRunning ) %  wait until the device has stopped.
                pause(0.01)
            end
        end
        
        
        %% call back functions for events
        function LogPressure(self, src, data)
            if isempty(self.pressure)
                self.pressure=data.data;
            else
                self.pressure(end+1)=data.data;
            end
        end
        %
        function LogResponse(self, src, data)
            if isempty(self.response)
                self.response(1,:)=data.data;
            else
                self.response(end+1,:)=data.data;
            end
            if size(self.response, 1) == self.N_trials
                self.IsDone  = true;
            end
        end
        
    end
end
