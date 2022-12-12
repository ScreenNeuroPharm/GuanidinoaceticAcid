function []=computePSTH (exp_num, fs, binsize, cancwin, psthend, peakfolder, psthfoldername1, psthfoldername2)
% Function for managing PSTH results, with parameters defined by the user
% INPUT VARIABLES
%           exp_num         = experiment number [char]
%           fs              = sampling frequency [samples/sec]
%           binsize         = PSTH bin - def by user [msec]
%           cancinw         = deleting artifact window - def by user [msec]
%           psthend         = time length of the histogram [msec]
%           %%%%%minarea         = minimum allowed PSTH area (not used for the moment)
%
%           peakfolder      = folder where peak_detection files are stored
%           psthfoldername1 = folder where storing the PSTH array -> with path
%           psthfoldername2 = folder where storing PSTH additional features -> with path
%
% OUTPUT VARIABLES
%
% by Michela Chiappalone (18-19 gennaio 2006)
% modified by Luca Leonardo Bologna (12 June 2007)
%   - in order to manage the 64 channels of MED64 panasonic system
% modified by M. Chiappalone on February 11, 2009, 
%   - in ordert o fix some bugs related to the filename of the saved data 
%     (if a 'point' in the name is present) and the possible presence 
%     of an empty latency_array

% DEFINE LOCAL VARIABLES
first=3;
latencyMAT= strcat (exp_num, 'PSTHlatency_MAT');
latencyTXT= strcat (exp_num, 'PSTHlatency_TXT');
stimwinMAT= strcat (exp_num, 'PSTHstimwin');
psthendsample=psthend*fs/1000;          % time length of the histogram [samples]
% -------------------------- START PROCESSING -----------------------------------
cd(peakfolder)                          % start_folder in the MAIN program
peakfolderdir=dir;                      % struct containing the peak-det folders
NumPeakFolder=length(peakfolderdir);    % number of experimental phases

for f= first:NumPeakFolder              % FOR cycle on the phase directories
    phasedir=peakfolderdir(f).name;
    [digifile, digipath] = uigetfile('.mat','Select Digi file');
    load(fullfile(digipath, digifile));

    % Modifica data in modo da renderlo compatibile con artifact
    % (il campione in cui si verifica lo stimolo)
    artifact_digi = diff(data);
    artifact_digi = find(artifact_digi ==1);
    
    if isempty (strfind(phasedir, 'asal')) && isempty(strfind(phasedir,'tetan')) % no PSTH for basal phases and tetanus
        newdir = strcat ('psth_', phasedir(8:end));
        cd (phasedir)
        phasedir= pwd;
        phasefiles= dir;
        NumPhaseFiles= length(phasefiles);
        rindex=0;
        latency_array= [];
        
        % new
        if length(phasefiles)-2 == 120
            mea = MEA120_lookuptable;
            mcmea_electrodes = double(mea(:,2));
            mea = mea(:,1);
            stimwin_cell=  cell (120,1);
        else
            mcmea_electrodes = [(12:17)'; (21:28)'; (31:38)'; (41:48)'; (51:58)'; (61:68)'; (71:78)';(82:87)'];
            stimwin_cell=  cell (88,1);
        end
        % 
 
        for i= first:NumPhaseFiles      % FOR cycle on the single directory files
            filename = phasefiles(i).name;         % current file
            electrode = split(filename,'.');
            electrode = split (electrode{1},'_');
            electrode = electrode{end};       % current electrode [char]
            check = regexprep(electrode,'[\d"]','');
            
            if ~isempty(check)
                el = mcmea_electrodes(strcmp(mea, electrode));
            else 
                el= str2num(electrode);                % current electrode [double]
            end
            
            load(filename);                       % 'peak_train' and 'artifact' are loaded
            if exist('artifact_digi', 'var')
                artifact = artifact_digi;
            end
            
            if (sum(artifact)>0) % only if we are considering a NOT basal phase we can compute PSTH
                [psthcnt, latency, stimwin_el]= psth (peak_train, artifact, fs, binsize, cancwin, psthend);
%                 if latency(1,1)>0
                    rindex=rindex+1;
                    latency_array(rindex,:)=[el, latency]; % save only the non zeros elements
                %end

                %if (sum(psthcnt)>0)             % I could put 'minarea' here
                    stimwin_cell{el, 1}= stimwin_el;

                    cd(psthfoldername1)         % move to dir for PSTH array saving
                    subdir=dir;
                    numsubdir=length(dir);
                    if isempty(strmatch(newdir, strvcat(subdir(1:numsubdir).name),'exact')) % check for existing dirs
                        mkdir (newdir)          % make a new directory only if it doesn't exist
                    end
                    cd (newdir)                 % change current dir
                    name =strcat(newdir, '_', electrode, '.mat');
                    save (name, 'psthcnt', '-mat')      % save PSTH files as .MAT files
                    clear subdir numsubdir name
                %end
            end
            cd (phasedir)
        end        

        % if sum(latency_array(:,1))>0 % old version with a BUG
        if ~isempty (latency_array)% if the latency_array is not empty
            cd(psthfoldername2)                     % move to dir for PSTH results saving
            subdir=dir;
            numsubdir=length(dir);

            % SAVE LATENCY MAT
            if isempty(strmatch(latencyMAT, strvcat(subdir(1:numsubdir).name),'exact')) % check for existing dirs
                mkdir (latencyMAT)                  % make a new directory only if it doesn't exist
            end
            cd (latencyMAT)                         % change current dir
            name =strcat('latencyMAT_', newdir, '.mat');
            save (name, 'latency_array', '-mat')            % save latency .MAT files
            cd(psthfoldername2)                     % go to the upper folder

            % SAVE LATENCY TXT
            if isempty(strmatch(latencyTXT, strvcat(subdir(1:numsubdir).name),'exact')) % check for existing dirs
                mkdir (latencyTXT)                  % make a new directory only if it doesn't exist
            end
            cd (latencyTXT)                         % change current dir
            name =strcat('latencyTXT_', newdir, '.txt');
            save (name, 'latency_array', '-ASCII'); % save latency .TXT files
            cd(psthfoldername2)                     % go to the upper folder

            % SAVE STIMWIN
            if isempty(strmatch(stimwinMAT, strvcat(subdir(1:numsubdir).name),'exact')) % check for existing dirs
                mkdir (stimwinMAT)                  % make a new directory only if it doesn't exist
            end
            cd (stimwinMAT)                         % change current dir
            name= strcat('stimwin_', newdir, '.mat');
            save (name, 'stimwin_cell', '-mat')               % save cell array stimwin
            clear name newdir subdir numsubdir
        end
    end
    cd(peakfolder)
end
