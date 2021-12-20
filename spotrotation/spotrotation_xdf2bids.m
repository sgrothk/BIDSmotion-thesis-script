% Wrapper input function for example data set spotrotation
% Author: Sein Jeung (seinjeung@gmail.com)

addpath('...\fieldtrip'); % add the modded fieldtrip 
addpath('...\bemobil-pipeline');

studyFolder                         = '...\spotrotation';
sessionNames                        = {'body', 'joy'};

% general metadata shared across all modalities
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
generalInfo = [];

% required for dataset_description.json
generalInfo.dataset_description.Name                = 'EEG and motion capture data set for a fully-body/joystick rotation task';
generalInfo.dataset_description.BIDSVersion         = 'unofficial extension';

% optional for dataset_description.json
generalInfo.dataset_description.License             = 'n/a';
generalInfo.dataset_description.Authors             = {"Gramann, K.", "Hohlefeld, F.U.", "Gehrke, L.", "Klug, M"};
generalInfo.dataset_description.Acknowledgements    = 'n/a';
generalInfo.dataset_description.Funding             = {""};
generalInfo.dataset_description.ReferencesAndLinks  = {"Human cortical dynamics during full-body heading changes", "https://doi.org/10.1038/s41598-021-97749-8"};
generalInfo.dataset_description.DatasetDOI          = 'n/a';

% general information shared across modality specific json files 
generalInfo.InstitutionName                         = 'Technische Universitaet zu Berlin';
generalInfo.InstitutionalDepartmentName             = 'Biological Psychology and Neuroergonomics';
generalInfo.InstitutionAddress                      = 'Strasse des 17. Juni 135, 10623, Berlin, Germany';
generalInfo.TaskDescription                         = 'Participants equipped with VR HMD rotated either physically or using a joystick.';
 

% information about the eeg recording system 
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
eegInfo     = [];
eegInfo.coordsystem.EEGCoordinateSystem = 'Other'; 
eegInfo.coordsystem.EEGCoordinateUnits = 'mm'; 
eegInfo.coordsystem.EEGCoordinateSystemDescription = 'ALS with origin between ears, measured with Xensor.'; 

                                                   
% information about the motion recording system 
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
motionInfo  = []; 

tracking_systems                                    = {'HTCVive', 'ImpluseX2', 'VIRPos'}; 

% motion specific fields in json
motionInfo.motion = [];
motionInfo.motion.RecordingType                     = 'continuous';

% system 1 information
motionInfo.motion.TrackingSystems.(tracking_systems{1}).Manufacturer                     = 'HTC';
motionInfo.motion.TrackingSystems.(tracking_systems{1}).ManufacturersModelName           = 'Vive Pro';
motionInfo.motion.TrackingSystems.(tracking_systems{1}).SamplingFrequencyNominal         = 90; %  If no nominal Fs exists, n/a entry returns 'n/a'. If it exists, n/a entry returns nominal Fs from motion stream.

% system 2 information
motionInfo.motion.TrackingSystems.(tracking_systems{2}).Manufacturer                     = 'PhaseSpace';
motionInfo.motion.TrackingSystems.(tracking_systems{2}).ManufacturersModelName           = 'ImpulseX2';
motionInfo.motion.TrackingSystems.(tracking_systems{2}).SamplingFrequencyNominal         = 90;

% system 3 information
motionInfo.motion.TrackingSystems.(tracking_systems{3}).Manufacturer                     = 'Virtual System Manufacturer';
motionInfo.motion.TrackingSystems.(tracking_systems{3}).ManufacturersModelName           = 'Virtual System Manufacturer Model';
motionInfo.motion.TrackingSystems.(tracking_systems{3}).SamplingFrequencyNominal         = 60;

% coordinate system
motionInfo.coordsystem.MotionCoordinateSystem      = 'RUF';
motionInfo.coordsystem.MotionRotationRule          = 'left-hand';
motionInfo.coordsystem.MotionRotationOrder         = 'ZXY';


% participant information 
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% here describe the fields in the participant file
% for numerical values  : 
%       subjectData.fields.[insert your field name here].Description    = 'describe what the field contains';
%       subjectData.fields.[insert your field name here].Unit           = 'write the unit of the quantity';
% for values with discrete levels :
%       subjectData.fields.[insert your field name here].Description    = 'describe what the field contains';
%       subjectData.fields.[insert your field name here].Levels.[insert the name of the first level] = 'describe what the level means';
%       subjectData.fields.[insert your field name here].Levels.[insert the name of the Nth level]   = 'describe what the level means';
%--------------------------------------------------------------------------
subjectInfo.fields.nr.Description       = 'numerical ID of the participant'; 
subjectInfo.fields.age.Description      = 'age of the participant'; 
subjectInfo.fields.age.Unit             = 'years'; 
subjectInfo.fields.sex.Description      = 'sex of the participant'; 
subjectInfo.fields.sex.Levels.M         = 'male'; 
subjectInfo.fields.sex.Levels.F         = 'female'; 
subjectInfo.fields.handedness.Description    = 'handedness of the participant';
subjectInfo.fields.handedness.Levels.R       = 'right-handed';
subjectInfo.fields.handedness.Levels.L       = 'left-handed';

% names of the columns - 'nr' column is just the numerical IDs of subjects
%                         do not change the name of this column
subjectInfo.cols = {'nr',   'age',  'sex',  'handedness'};
subjectInfo.data = {1,     30,     'F',     'R' ; ...
                    2,     22,     'M',     'R'; ...
                    3,     23,     'F',     'R'; ...
                    4,     34,     'M',     'R'; ...
                    5,     25,     'F',     'R'; ...
                    6,     21,     'F',     'R' ; ...
                    7,     28,     'M',     'R'; ...
                    8,     28,     'M',     'R'; ...
                    9,     24,     'F',     'R'; ...
                    10,    25,     'F',     'L'; ...
                    11,    30,     'F',     'R'; ...
                    12,    22,     'M',     'R'; ...
                    13,    23,     'F',     'R'; ...
                    14,    34,     'M',     'R'; ...
                    15,    25,     'F',     'R'; ...
                    16,    21,     'F',     'R' ; ...
                    17,    28,     'M',     'R'; ...
                    18,    28,     'M',     'R'; ...
                    19,    24,     'F',     'R'; ...
                    20,    25,     'F',     'L';};
               


% loop over participants
for subject = [6,7,8,9,10]
   
    % loop over sessions 
    for session = 1:2
                
        config                        = [];                                 % reset for each loop 
        config.bids_target_folder     = '...\1_BIDS-data-full'; % required
        
        if subject > 5 && subject < 11
            config.filename               = fullfile(['...\spotrotation\0_source-data\vp-' num2str(subject) '\additional_data\test_' sessionNames{session} '.xdf']); % required
            config.eeg.chanloc            = fullfile(['...\spotrotation\0_source-data\vp-' num2str(subject) '\channel_locations.elc']); % optional 
        else 
            config.filename               = fullfile(['...\spotrotation\0_source-data\' num2str(subject) '\test_' sessionNames{session} '.xdf']); % required
            config.eeg.chanloc            = fullfile(['...\spotrotation\0_source-data\' num2str(subject) '\channel_locations.elc']); % optional 
        end
        
        config.task                   = 'Rotation';                         % optional
        config.subject                = subject;                            % required
        config.session                = sessionNames{session};              % optional
        config.overwrite              = 'on';
        
        config.eeg.stream_name        = 'BrainVision';                      % required
        
        if session == 1
            config.motion.streams{1}.stream_name        = 'headrigid';
            config.motion.streams{1}.tracking_system    = 'HTCVive';
            config.motion.streams{1}.tracked_points     = 'headRigid';
            config.motion.streams{1}.tracked_points_anat= 'head';
            
            if subject ~= 13 && subject ~= 16 && subject ~= 19 && subject ~= 20 % subject ~= 6 && subject ~= 13 && subject ~= 19 && subject ~= 20 % subject 6 missing phasespace data and sub 13, 19, 20 has all zero stream
                config.motion.streams{2}.stream_name        = 'AllPhaseSpace';
                config.motion.streams{2}.tracking_system    = 'ImpulseX2';
                config.motion.streams{2}.tracked_points     = {'Rigid1', 'Rigid2', 'Rigid3', 'Rigid4'};
            end
  else
            config.motion.streams{1}.stream_name        = 'head';
            config.motion.streams{1}.tracking_system    = 'VIRPos';
            config.motion.streams{1}.tracked_points     = 'headRigid';
            config.motion.POS.unit                      = 'vm';
        end
        config.motion.custom_function                   = 'spotrotation_motionconvert';
        
        % config.phys.streams{1}.stream_name              = []; % optional in case phys streams are present
        
        bemobil_xdf2bids(config, ...
            'general_metadata', generalInfo,...
            'participant_metadata', subjectInfo,...
            'motion_metadata', motionInfo, ...
            'eeg_metadata', eegInfo);
        
    end
    
    % configuration for bemobil bids2set
    %----------------------------------------------------------------------
    config.study_folder             = studyFolder;
    config.session_names            = sessionNames; 
    config.raw_EEGLAB_data_folder   = '2_raw-EEGLAB-full';
    
    % match labels in electrodes.tsv and channels.tsv 
    matchlocs = {}; 
    letters = {'g', 'y', 'r', 'w', 'n'}; 
    for Li = 1:numel(letters)
        letter = letters{Li}; 
        for Ni = 1:32
            matchlocs{Ni + (Li-1)*32,1} = [letter num2str(Ni)]; % channel name in electrodes.tsv
            matchlocs{Ni + (Li-1)*32,2} = ['BrainVision RDA_' upper(letter) num2str(Ni, '%02.f')]; % channel name in channels.tsv 
        end
    end
    
    [matchlocs{157:159,1}] = deal(''); 
    config.match_electrodes_channels = matchlocs; 
    
    %bemobil_bids2set(config);
    
end

%         % optional run processing 
%         if participant == 1 && session == 1
%             for run = 1:3
%                 config.filename              = ['rec' num2str(run) '.xdf']; 
%                 config.run                   = run;                           
%                 bemobil_xdf2bids(config, ...
%                     'general_metadata', generalInfo,...
%                     'participant_metadata', participnatInfo,...
%                     'motion_metadata', motionInfo, ...
%                     'eeg_metadata', eegInfo);
%             end
%         else 
%             bemobil_xdf2bids(config, ...
%                 'general_metadata', generalInfo,...
%                 'participant_metadata', participnatInfo,...
%                 'motion_metadata', motionInfo, ...
%                 'eeg_metadata', eegInfo);
%         end
    