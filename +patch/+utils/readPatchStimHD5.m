function [data, settings, ver] = readPatchStimHD5(F)
% F: Key structure or full filename including path (for example '/path/Patchfile10.h5') 
% 
% data: all variables extracted from file
% settings: settings telegraphs from NPI amp
% ver: file version

if isstruct(F)
    f = fetch1(patch.Recording & F,'filename');
    p = fetch1(patch.Session & F,'path');
    
    if strcmp(computer,'GLNXA64')
        F = ['/mnt' p '/' f ]
    else
        F = regexprep(['C:' p '/' f],{'/scratch01/','\/'},'\\');
    end
end
    
f=dir(F);

% Check file exists
assert(length(f)==1,['Cannot find file ' F]);

% Use 'Date Modified' to determine file version
if f.datenum > datenum('2013-04-06 08:00') && f.datenum < datenum('2013-04-17 08:00')
    fileV = 1;
elseif f.datenum > datenum('2013-04-17 08:00') && f.datenum < datenum('2013-10-26 08:00')
    fileV = 2;
elseif f.datenum > datenum('2013-10-26 08:00') && f.datenum < datenum('2013-10-30 08:00')
    fileV = 3;
elseif f.datenum > datenum('2013-10-30 08:00') && f.datenum < datenum('2013-11-07 08:00')
    fileV = 2;
elseif f.datenum > datenum('2013-11-07 08:00') && f.datenum < datenum('2013-11-10 08:00')
    fileV = 4;
elseif f.datenum > datenum('2013-11-10 08:00') && f.datenum < datenum('2014-01-21 08:00')
    fileV = 5;
elseif f.datenum > datenum('2014-01-21 08:00') && f.datenum < datenum('2014-01-24 08:00')
    fileV = 4;
elseif f.datenum > datenum('2014-01-24 08:00') && f.datenum < datenum('2014-03-28 08:00')
    fileV = 5;
elseif f.datenum > datenum('2014-03-28 08:00') && f.datenum < datenum('2014-06-03 08:00')
    fileV = 6;
elseif f.datenum > datenum('2014-06-03 08:00') %%&& f.datenum < datenum('')
    fileV = 7;
else
    error('File version not known');
end

% Append '%d.h5' to filename in place of trailing 'x.h5'
F = [F(1:end-4) '%d.h5'];

ver = fileV;
switch fileV
    case 1
        %% Files recorded between 04-06-2013 and/on 04-16-2013 using only the NPI ELC-03XS amplifier
        % open file using family driver
        fapl = H5P.create('H5P_FILE_ACCESS');
        H5P.set_fapl_family(fapl,2^31,'H5P_DEFAULT');
        fp = H5F.open(F,'H5F_ACC_RDONLY',fapl);
        H5P.close(fapl);
        
        %data1d = H5Tools.readDataset(fp,'dataset1d')
        data.ball = H5Tools.readDataset(fp,'ball') ;
        wf = H5Tools.readDataset(fp,'waveform') ;
        sets = H5Tools.readDataset(fp,'settings') ;
        data.cam1ts = H5Tools.readDataset(fp,'behaviorvideotimestamp') ;
        data.cam2ts = H5Tools.readDataset(fp,'eyetrackingvideotimestamp') ;
        
        waveformDescStr=H5Tools.readAttribute(fp,'waveform Channels Description')';
        assert(strcmp(deblank(waveformDescStr),'Current, Voltage, Sync Photodiode, Stimulation Photodiode, LED Level Input, Patch Command Input, Shutter'),...
            'waveform Channels Description is wrong for this file version');
        
        settingsDescStr=H5Tools.readAttribute(fp,'settings Channels Description')';
        assert(strcmp(deblank(settingsDescStr),'Current Gain, Voltage Gain, Current Low Pass, Voltage Low Pass, Voltage High Pass'),...
            'settings Channels Description is wrong for this file version');
        
        % convert waveform to structure
        data.i1 = wf(:,1);
        data.v1 = wf(:,2);
        data.syncPd = wf(:,3);
        data.stimPd = wf(:,4);
        data.led = wf(:,5);
        data.command = wf(:,6);
        data.shutter = wf(:,7);
        data.ts = wf(:,8);
        
        % deal with setting  telegraphs on NPI amp
        iGains = [0.1 0.2 0.5 1 2 5 10];
        settings.iGain = iGains(unique(round(sets(:,1))));
        assert(length(settings.iGain)==1,'Current gain changed during recording');
        
        vGains = [10 20 50 100 200 500 1000];
        settings.vGain = vGains(unique(round(sets(:,2))));
        assert(length(settings.vGain)==1,'Voltage gain changed during recording');
        
        iLowPassCorners = [20 50 100 200 300 500 700 1000 1300 2000 3000 5000 8000 10000 13000 20000];
        settings.iLowPass = iLowPassCorners(unique(round(sets(:,3)))+9);
        assert(length(settings.vGain)==1,'Current low pass filter changed during recording');
        
        vLowPassCorners = [20 50 100 200 300 500 700 1000 1300 2000 3000 5000 8000 10000 13000 20000];
        settings.vLowPass = vLowPassCorners(unique(round(sets(:,4)))+9);
        assert(length(settings.vGain)==1,'Voltage low pass filter changed during recording');
        
        vHighPassCorners = [0 0.1 0.3 0.5 1 3 5 10 30 50 100 300 500 800 1000 3000];
        settings.vHighPass = vHighPassCorners(unique(round(sets(:,5)))+9);
        assert(length(settings.vGain)==1,'Voltage high pass filter changed during recording');
        
        % apply gains to voltage and current
        data.v1 = data.v1/settings.vGain;
        data.i1 = data.i1/settings.iGain;
        
        H5F.close(fp);
        
        
    case 2
        %% Files recorded on/after 04-17-2013 using the NPI ELC-03XS amplifier as amp 1 and the AxoClamp 2B (.1x headstage) as amp 2
        % open file using family driver
        fapl = H5P.create('H5P_FILE_ACCESS');
        H5P.set_fapl_family(fapl,2^31,'H5P_DEFAULT');
        fp = H5F.open(F,'H5F_ACC_RDONLY',fapl);
        H5P.close(fapl);
        
        %data1d = H5Tools.readDataset(fp,'dataset1d')
        data.ball = H5Tools.readDataset(fp,'ball') ;
        wf = H5Tools.readDataset(fp,'waveform') ;
        sets = H5Tools.readDataset(fp,'settings') ;
        data.cam1ts = H5Tools.readDataset(fp,'behaviorvideotimestamp') ;
        data.cam2ts = H5Tools.readDataset(fp,'eyetrackingvideotimestamp') ;
        
        waveformDescStr=H5Tools.readAttribute(fp,'waveform Channels Description')';
        assert(strcmp(deblank(waveformDescStr),'Current Input 1, Voltage Input 1, Sync Photodiode, Stimulation Photodiode, LED Level Input, Patch Command Input, Shutter, Current Input 2, Voltage Input 2'),...
            'waveform Channels Description is wrong for this file version');
        
        settingsDescStr=H5Tools.readAttribute(fp,'settings Channels Description')';
        assert(strcmp(deblank(settingsDescStr),'Current Gain, Voltage Gain, Current Low Pass, Voltage Low Pass, Voltage High Pass'),...
            'settings Channels Description is wrong for this file version');
        
        %convert waveform to structure
        data.i1 = wf(:,1);
        data.v1 = wf(:,2);
        data.i2 = wf(:,8);
        data.v2 = wf(:,9);
        data.syncPd = wf(:,3);
        data.stimPd = wf(:,4);
        data.led = wf(:,5);
        data.command = wf(:,6);
        data.shutter = wf(:,7);
        data.ts = wf(:,10);
        
        % deal with setting telegraphs on NPI amp
        iGains = [0.1 0.2 0.5 1 2 5 10];
        settings.iGain = iGains(unique(round(sets(:,1))));
        assert(length(settings.iGain)==1,'Current gain changed during recording');
        
        vGains = [10 20 50 100 200 500 1000];
        settings.vGain = vGains(unique(round(sets(:,2))));
        assert(length(settings.vGain)==1,'Voltage gain changed during recording');
        
        iLowPassCorners = [20 50 100 200 300 500 700 1000 1300 2000 3000 5000 8000 10000 13000 20000];
        settings.iLowPass = iLowPassCorners(unique(round(sets(:,3)))+9);
        assert(length(settings.vGain)==1,'Current low pass filter changed during recording');
        
        vLowPassCorners = [20 50 100 200 300 500 700 1000 1300 2000 3000 5000 8000 10000 13000 20000];
        settings.vLowPass = vLowPassCorners(unique(round(sets(:,4)))+9);
        assert(length(settings.vGain)==1,'Voltage low pass filter changed during recording');
        
        vHighPassCorners = [0 0.1 0.3 0.5 1 3 5 10 30 50 100 300 500 800 1000 3000];
        settings.vHighPass = vHighPassCorners(unique(round(sets(:,5)))+9);
        assert(length(settings.vGain)==1,'Voltage high pass filter changed during recording');
        
        
        % settings on AxoClamp 2B are constant
        settings(2).iGain = 0.1;
        settings(2).vGain = 10;
        settings(2).vLowPass = 30000;
        settings(2).iLowPass = 30000;
        settings(2).vHighPass = 0;
        
        % apply gains to voltage and current
        data.v1 = data.v1/settings(1).vGain;
        data.i1 = data.i1/settings(1).iGain;
        data.v2 = data.v2/settings(2).vGain;
        data.i2 = data.i2/settings(2).iGain;
        
        H5F.close(fp);
        
    case 3
        %% Files recorded on/after 10-26-2013 using the NPI ELC-03XS amplifier as amp 1 and the AxoClamp 2B (.1x headstage) as amp 2
        %% Accounts for problem with NPI ELC-03XS amplifier where voltage reading is halved.
        
        % open file using family driver
        fapl = H5P.create('H5P_FILE_ACCESS');
        H5P.set_fapl_family(fapl,2^31,'H5P_DEFAULT');
        fp = H5F.open(F,'H5F_ACC_RDONLY',fapl);
        H5P.close(fapl);
        
        %data1d = H5Tools.readDataset(fp,'dataset1d')
        data.ball = H5Tools.readDataset(fp,'ball') ;
        wf = H5Tools.readDataset(fp,'waveform') ;
        sets = H5Tools.readDataset(fp,'settings') ;
        data.cam1ts = H5Tools.readDataset(fp,'behaviorvideotimestamp') ;
        data.cam2ts = H5Tools.readDataset(fp,'eyetrackingvideotimestamp') ;
        
        waveformDescStr=H5Tools.readAttribute(fp,'waveform Channels Description')';
        assert(strcmp(deblank(waveformDescStr),'Current Input 1, Voltage Input 1, Sync Photodiode, Stimulation Photodiode, LED Level Input, Patch Command Input, Shutter, Current Input 2, Voltage Input 2'),...
            'waveform Channels Description is wrong for this file version');
        
        settingsDescStr=H5Tools.readAttribute(fp,'settings Channels Description')';
        assert(strcmp(deblank(settingsDescStr),'Current Gain, Voltage Gain, Current Low Pass, Voltage Low Pass, Voltage High Pass'),...
            'settings Channels Description is wrong for this file version');
        
        %convert waveform to structure
        data.i1 = wf(:,1);
        data.v1 = wf(:,2);
        data.i2 = wf(:,8);
        data.v2 = wf(:,9);
        data.syncPd = wf(:,3);
        data.stimPd = wf(:,4);
        data.led = wf(:,5);
        data.command = wf(:,6);
        data.shutter = wf(:,7);
        data.ts = wf(:,10);
        
        % deal with setting telegraphs on NPI amp
        iGains = [0.1 0.2 0.5 1 2 5 10];
        settings.iGain = iGains(unique(round(sets(:,1))));
        assert(length(settings.iGain)==1,'Current gain changed during recording');
        
        vGains = [10 20 50 100 200 500 1000];
        settings.vGain = vGains(unique(round(sets(:,2))));
        assert(length(settings.vGain)==1,'Voltage gain changed during recording');
        
        iLowPassCorners = [20 50 100 200 300 500 700 1000 1300 2000 3000 5000 8000 10000 13000 20000];
        settings.iLowPass = iLowPassCorners(unique(round(sets(:,3)))+9);
        assert(length(settings.vGain)==1,'Current low pass filter changed during recording');
        
        vLowPassCorners = [20 50 100 200 300 500 700 1000 1300 2000 3000 5000 8000 10000 13000 20000];
        settings.vLowPass = vLowPassCorners(unique(round(sets(:,4)))+9);
        assert(length(settings.vGain)==1,'Voltage low pass filter changed during recording');
        
        vHighPassCorners = [0 0.1 0.3 0.5 1 3 5 10 30 50 100 300 500 800 1000 3000];
        settings.vHighPass = vHighPassCorners(unique(round(sets(:,5)))+9);
        assert(length(settings.vGain)==1,'Voltage high pass filter changed during recording');
        
        % settings on AxoClamp 2B are constant
        settings(2).iGain = 0.1;
        settings(2).vGain = 10;
        settings(2).vLowPass = 30000;
        settings(2).iLowPass = 30000;
        settings(2).vHighPass = 0;
        
        % apply gains to voltage and current
        data.v1 = (data.v1/settings(1).vGain) * 2;  % ******************* Mupltiply voltage reading by 2 ********************
        data.i1 = data.i1/settings(1).iGain;
        data.v2 = data.v2/settings(2).vGain;
        data.i2 = data.i2/settings(2).iGain;
        
        H5F.close(fp);
        
    case 4
        %% Files recorded on 11-07-2013 and 11-08-2013 on the AxoClamp 2B (.1x headstage) as amp 2
        %% Gives constant values for settings on unused amp 1 - ignore these
        %% Used after 11-08-2013 on days that don't include patching data (i.e. when only camera data is recorded)
        %% Sets iLowpass on amp 2 at 3000Hz, which is correct.
        
        % open file using family driver
        fapl = H5P.create('H5P_FILE_ACCESS');
        H5P.set_fapl_family(fapl,2^31,'H5P_DEFAULT');
        fp = H5F.open(F,'H5F_ACC_RDONLY',fapl);
        H5P.close(fapl);
        
        %data1d = H5Tools.readDataset(fp,'dataset1d')
        data.ball = H5Tools.readDataset(fp,'ball') ;
        wf = H5Tools.readDataset(fp,'waveform') ;
        sets = H5Tools.readDataset(fp,'settings') ;
        data.cam1ts = H5Tools.readDataset(fp,'behaviorvideotimestamp') ;
        data.cam2ts = H5Tools.readDataset(fp,'eyetrackingvideotimestamp') ;
        
        waveformDescStr=H5Tools.readAttribute(fp,'waveform Channels Description')';
        assert(strcmp(deblank(waveformDescStr),'Current Input 1, Voltage Input 1, Sync Photodiode, Stimulation Photodiode, LED Level Input, Patch Command Input, Shutter, Current Input 2, Voltage Input 2'),...
            'waveform Channels Description is wrong for this file version');
        
        settingsDescStr=H5Tools.readAttribute(fp,'settings Channels Description')';
        assert(strcmp(deblank(settingsDescStr),'Current Gain, Voltage Gain, Current Low Pass, Voltage Low Pass, Voltage High Pass'),...
            'settings Channels Description is wrong for this file version');
        
        %convert waveform to structure
        data.i1 = wf(:,1);
        data.v1 = wf(:,2);
        data.i2 = wf(:,8);
        data.v2 = wf(:,9);
        data.syncPd = wf(:,3);
        data.stimPd = wf(:,4);
        data.led = wf(:,5);
        data.command = wf(:,6);
        data.shutter = wf(:,7);
        data.ts = wf(:,10);
        
        % constant settings on unused NPI amp
        
        settings.iGain = 1;
        settings.vGain = 1;
        settings.iLowPass = 1;
        settings.vLowPass = 1;
        settings.vHighPass = 1;
        
        % settings on AxoClamp 2B are constant
        settings(2).iGain = 0.1;
        settings(2).vGain = 10;
        settings(2).vLowPass = 30000;
        settings(2).iLowPass = 3000;   % This is correct
        settings(2).vHighPass = 0;
        
        % apply gains to voltage and current
        data.v1 = (data.v1/settings(1).vGain);
        data.i1 = data.i1/settings(1).iGain;
        data.v2 = data.v2/settings(2).vGain;
        data.i2 = data.i2/settings(2).iGain;
        
        H5F.close(fp);
        
    case 5
        %% Files recorded after 11-10-2013 using the NPI ELC-03XS amplifier as amp 1 and the AxoClamp 2B (.1x headstage) as amp 2
        %% Amp 2 current low-pass is set to 3000Hz.
        %% Skips settings telegraph from NPI if any(~sets), i.e. if NPI amp is turned off.
        % open file using family driver
        fapl = H5P.create('H5P_FILE_ACCESS');
        H5P.set_fapl_family(fapl,2^31,'H5P_DEFAULT');
        fp = H5F.open(F,'H5F_ACC_RDONLY',fapl);
        H5P.close(fapl);
        
        %data1d = H5Tools.readDataset(fp,'dataset1d')
        data.ball = H5Tools.readDataset(fp,'ball') ;
        wf = H5Tools.readDataset(fp,'waveform') ;
        sets = H5Tools.readDataset(fp,'settings') ;
        data.cam1ts = H5Tools.readDataset(fp,'behaviorvideotimestamp') ;
        data.cam2ts = H5Tools.readDataset(fp,'eyetrackingvideotimestamp') ;
        
        waveformDescStr=H5Tools.readAttribute(fp,'waveform Channels Description')';
        assert(strcmp(deblank(waveformDescStr),'Current Input 1, Voltage Input 1, Sync Photodiode, Stimulation Photodiode, LED Level Input, Patch Command Input, Shutter, Current Input 2, Voltage Input 2'),...
            'waveform Channels Description is wrong for this file version');
        
        settingsDescStr=H5Tools.readAttribute(fp,'settings Channels Description')';
        assert(strcmp(deblank(settingsDescStr),'Current Gain, Voltage Gain, Current Low Pass, Voltage Low Pass, Voltage High Pass'),...
            'settings Channels Description is wrong for this file version');
        
        %convert waveform to structure
        data.i1 = wf(:,1);
        data.v1 = wf(:,2);
        data.i2 = wf(:,8);
        data.v2 = wf(:,9);
        data.syncPd = wf(:,3);
        data.stimPd = wf(:,4);
        data.led = wf(:,5);
        data.command = wf(:,6);
        data.shutter = wf(:,7);
        data.ts = wf(:,10);
        
        if ~any(~round(sets(:)))
            % deal with setting telegraphs on NPI amp
            iGains = [0.1 0.2 0.5 1 2 5 10];
            settings.iGain = iGains(unique(round(sets(:,1))));
            assert(length(settings.iGain)==1,'Current gain changed during recording');
            
            vGains = [10 20 50 100 200 500 1000];
            settings.vGain = vGains(unique(round(sets(:,2))));
            assert(length(settings.vGain)==1,'Voltage gain changed during recording');
            
            iLowPassCorners = [20 50 100 200 300 500 700 1000 1300 2000 3000 5000 8000 10000 13000 20000];
            settings.iLowPass = iLowPassCorners(unique(round(sets(:,3)))+9);
            assert(length(settings.vGain)==1,'Current low pass filter changed during recording');
            
            vLowPassCorners = [20 50 100 200 300 500 700 1000 1300 2000 3000 5000 8000 10000 13000 20000];
            settings.vLowPass = vLowPassCorners(unique(round(sets(:,4)))+9);
            assert(length(settings.vGain)==1,'Voltage low pass filter changed during recording');
            
            vHighPassCorners = [0 0.1 0.3 0.5 1 3 5 10 30 50 100 300 500 800 1000 3000];
            settings.vHighPass = vHighPassCorners(unique(round(sets(:,5)))+9);
            assert(length(settings.vGain)==1,'Voltage high pass filter changed during recording');
        else
            % constant settings on unused NPI amp
            
            settings.iGain = 1;
            settings.vGain = 1;
            settings.iLowPass = 1;
            settings.vLowPass = 1;
            settings.vHighPass = 1;
            warning('Unable to read settings telegraphs from NPI Amp');
        end
        
        
        % settings on AxoClamp 2B are constant
        settings(2).iGain = 0.1;
        settings(2).vGain = 10;
        settings(2).vLowPass = 30000;
        settings(2).iLowPass = 3000;
        settings(2).vHighPass = 0;
        
        % apply gains to voltage and current
        data.v1 = data.v1/settings(1).vGain;
        data.i1 = data.i1/settings(1).iGain;
        data.v2 = data.v2/settings(2).vGain;
        data.i2 = data.i2/settings(2).iGain;
        
        H5F.close(fp);
    case 6
        %% Files recorded after 03-28-2014 using the NPI ELC-03XS amplifier as amp 1 and the AxoClamp 2B (.1x headstage) as amp 2
        %% Amp 2 current low-pass is set to 3000Hz.
        %% Skips settings telegraph from NPI if any(~sets), i.e. if NPI amp is turned off.
        %% Adds scanimage sync channel
        %% Ball data is from optical encoder
        
        % open file using family driver
        fapl = H5P.create('H5P_FILE_ACCESS');
        H5P.set_fapl_family(fapl,2^31,'H5P_DEFAULT');
        fp = H5F.open(F,'H5F_ACC_RDONLY',fapl);
        H5P.close(fapl);
        
        %data1d = H5Tools.readDataset(fp,'dataset1d')
        data.ball = H5Tools.readDataset(fp,'ball') ;
        wf = H5Tools.readDataset(fp,'waveform') ;
        sets = H5Tools.readDataset(fp,'settings') ;
        data.cam1ts = H5Tools.readDataset(fp,'behaviorvideotimestamp') ;
        data.cam2ts = H5Tools.readDataset(fp,'eyetrackingvideotimestamp') ;
        
        waveformDescStr=H5Tools.readAttribute(fp,'waveform Channels Description')';
        assert(strcmp(deblank(waveformDescStr),'Current Input 1, Voltage Input 1, Sync Photodiode, Stimulation Photodiode, LED Level Input, Patch Command Input, Shutter, Current Input 2, Voltage Input 2, Scan Image Sync'),...
            'waveform Channels Description is wrong for this file version');
        
        settingsDescStr=H5Tools.readAttribute(fp,'settings Channels Description')';
        assert(strcmp(deblank(settingsDescStr),'Current Gain, Voltage Gain, Current Low Pass, Voltage Low Pass, Voltage High Pass'),...
            'settings Channels Description is wrong for this file version');
        
        %convert waveform to structure
        data.i1 = wf(:,1);
        data.v1 = wf(:,2);
        data.i2 = wf(:,8);
        data.v2 = wf(:,9);
        data.syncPd = wf(:,3);
        data.stimPd = wf(:,4);
        data.led = wf(:,5);
        data.command = wf(:,6);
        data.shutter = wf(:,7);
        data.scanImage = wf(:,10);
        data.ts = wf(:,11);
        
        if ~any(~round(sets(:)))
            % deal with setting telegraphs on NPI amp
            iGains = [0.1 0.2 0.5 1 2 5 10];
            settings.iGain = iGains(unique(round(sets(:,1))));
            assert(length(settings.iGain)==1,'Current gain changed during recording');
            
            vGains = [10 20 50 100 200 500 1000];
            settings.vGain = vGains(unique(round(sets(:,2))));
            assert(length(settings.vGain)==1,'Voltage gain changed during recording');
            
            iLowPassCorners = [20 50 100 200 300 500 700 1000 1300 2000 3000 5000 8000 10000 13000 20000];
            settings.iLowPass = iLowPassCorners(unique(round(sets(:,3)))+9);
            assert(length(settings.vGain)==1,'Current low pass filter changed during recording');
            
            vLowPassCorners = [20 50 100 200 300 500 700 1000 1300 2000 3000 5000 8000 10000 13000 20000];
            settings.vLowPass = vLowPassCorners(unique(round(sets(:,4)))+9);
            assert(length(settings.vGain)==1,'Voltage low pass filter changed during recording');
            
            vHighPassCorners = [0 0.1 0.3 0.5 1 3 5 10 30 50 100 300 500 800 1000 3000];
            settings.vHighPass = vHighPassCorners(unique(round(sets(:,5)))+9);
            assert(length(settings.vGain)==1,'Voltage high pass filter changed during recording');
        else
            % constant settings on unused NPI amp
            
            settings.iGain = 1;
            settings.vGain = 1;
            settings.iLowPass = 1;
            settings.vLowPass = 1;
            settings.vHighPass = 1;
            warning('Unable to read settings telegraphs from NPI Amp');
        end
        
        
        % settings on AxoClamp 2B are constant
        settings(2).iGain = 0.1;
        settings(2).vGain = 10;
        settings(2).vLowPass = 30000;
        settings(2).iLowPass = 3000;
        settings(2).vHighPass = 0;
        
        % apply gains to voltage and current
        data.v1 = data.v1/settings(1).vGain;
        data.i1 = data.i1/settings(1).iGain;
        data.v2 = data.v2/settings(2).vGain;
        data.i2 = data.i2/settings(2).iGain;
        
        
        H5F.close(fp);
    case 7
        %% Files recorded after 03-28-2014 using the NPI ELC-03XS amplifier as amp 1 and the AxoClamp 2B (.1x headstage) as amp 2
        %% Amp 2 current low-pass is set to 3000Hz.
        %% Skips settings telegraph from NPI if any(~sets), i.e. if NPI amp is turned off.
        %% Adds scanimage sync channel
        %% Ball data is from optical encoder
        %% ts2sec now takes 'packetLen' argument in order to correctly assign timestamps to end of data packets. This version adds a analogPacketLen field to data struct
        
        % *** Packet length is set at 2000 for analog channels ***
        ANALOG_PACKET_LEN = 2000;
        
        % open file using family driver
        fapl = H5P.create('H5P_FILE_ACCESS');
        H5P.set_fapl_family(fapl,2^31,'H5P_DEFAULT');
        fp = H5F.open(F,'H5F_ACC_RDONLY',fapl);
        H5P.close(fapl);
        
        %data1d = H5Tools.readDataset(fp,'dataset1d')
        data.ball = H5Tools.readDataset(fp,'ball') ;
        wf = H5Tools.readDataset(fp,'waveform') ;
        sets = H5Tools.readDataset(fp,'settings') ;
        data.cam1ts = H5Tools.readDataset(fp,'behaviorvideotimestamp') ;
        data.cam2ts = H5Tools.readDataset(fp,'eyetrackingvideotimestamp') ;
        
        waveformDescStr=H5Tools.readAttribute(fp,'waveform Channels Description')';
        assert(strcmp(deblank(waveformDescStr),'Current Input 1, Voltage Input 1, Sync Photodiode, Stimulation Photodiode, LED Level Input, Patch Command Input, Shutter, Current Input 2, Voltage Input 2, Scan Image Sync'),...
            'waveform Channels Description is wrong for this file version');
        
        settingsDescStr=H5Tools.readAttribute(fp,'settings Channels Description')';
        assert(strcmp(deblank(settingsDescStr),'Current Gain, Voltage Gain, Current Low Pass, Voltage Low Pass, Voltage High Pass'),...
            'settings Channels Description is wrong for this file version');
        
        %convert waveform to structure
        data.i1 = wf(:,1);
        data.v1 = wf(:,2);
        data.i2 = wf(:,8);
        data.v2 = wf(:,9);
        data.syncPd = wf(:,3);
        data.stimPd = wf(:,4);
        data.led = wf(:,5);
        data.command = wf(:,6);
        data.shutter = wf(:,7);
        data.scanImage = wf(:,10);
        data.ts = wf(:,11);
        data.analogPacketLen = ANALOG_PACKET_LEN;
        
        if ~any(~round(sets(:)))
            % deal with setting telegraphs on NPI amp
            iGains = [0.1 0.2 0.5 1 2 5 10];
            settings.iGain = iGains(unique(round(sets(:,1))));
            assert(length(settings.iGain)==1,'Current gain changed during recording');
            
            vGains = [10 20 50 100 200 500 1000];
            settings.vGain = vGains(unique(round(sets(:,2))));
            assert(length(settings.vGain)==1,'Voltage gain changed during recording');
            
            iLowPassCorners = [20 50 100 200 300 500 700 1000 1300 2000 3000 5000 8000 10000 13000 20000];
            settings.iLowPass = iLowPassCorners(unique(round(sets(:,3)))+9);
            assert(length(settings.vGain)==1,'Current low pass filter changed during recording');
            
            vLowPassCorners = [20 50 100 200 300 500 700 1000 1300 2000 3000 5000 8000 10000 13000 20000];
            settings.vLowPass = vLowPassCorners(unique(round(sets(:,4)))+9);
            assert(length(settings.vGain)==1,'Voltage low pass filter changed during recording');
            
            vHighPassCorners = [0 0.1 0.3 0.5 1 3 5 10 30 50 100 300 500 800 1000 3000];
            settings.vHighPass = vHighPassCorners(unique(round(sets(:,5)))+9);
            assert(length(settings.vGain)==1,'Voltage high pass filter changed during recording');
        else
            % constant settings on unused NPI amp
            
            settings.iGain = 1;
            settings.vGain = 1;
            settings.iLowPass = 1;
            settings.vLowPass = 1;
            settings.vHighPass = 1;
            warning('Unable to read settings telegraphs from NPI Amp');
        end
        
        
        % settings on AxoClamp 2B are constant
        settings(2).iGain = 0.1;
        settings(2).vGain = 10;
        settings(2).vLowPass = 30000;
        settings(2).iLowPass = 3000;
        settings(2).vHighPass = 0;
        
        % apply gains to voltage and current
        data.v1 = data.v1/settings(1).vGain;
        data.i1 = data.i1/settings(1).iGain;
        data.v2 = data.v2/settings(2).vGain;
        data.i2 = data.i2/settings(2).iGain;
        
        
        H5F.close(fp);
end
