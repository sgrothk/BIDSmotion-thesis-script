% Wrapper input function for example data set walking young and old
% Author: Sein Jeung (seinjeung@gmail.com)

addpath('...\fieldtrip'); % add the modded fieldtrip 
addpath('...\bemobil-pipeline');

studyFolder                         = '...\walking young and old';
sessionNames                        = {'walk', 'stand'};

% general metadata shared across all modalities
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
generalInfo = [];

% required for dataset_description.json
generalInfo.dataset_description.Name                = 'Walking task in the young and old';
generalInfo.dataset_description.BIDSVersion         = 'unofficial extension';

% optional for dataset_description.json
generalInfo.dataset_description.License             = 'CC BY 4.0';
generalInfo.dataset_description.Authors             = {'Janna Protzak', 'Klaus Gramann'};
generalInfo.dataset_description.Acknowledgements    = 'n/a';
generalInfo.dataset_description.Funding             = {'This Study was realized by funding from the Federal Ministry of Education and Research (BMBF)'};
generalInfo.dataset_description.ReferencesAndLinks  = {'n/a'};
generalInfo.dataset_description.DatasetDOI          = 'n/a';

% general information shared across modality specific json files 
generalInfo.InstitutionName                         = 'Technische Universitaet Berlin';
generalInfo.InstitutionalDepartmentName             = 'Junior research group FANS (Pedestrian Assistance System for Older Road Users), Department of Psychology and Ergonomics';
generalInfo.InstitutionAddress                      = 'Marchstr. 23, 10587, Berlin, Germany';
generalInfo.TaskDescription                         = 'Younger and older adults performed a visual discrimination task (button presses to peripheral presented LED flashes) during walking. Visual targets were either presented with or without preceding vibro-tactile cues';
 

% information about the eeg recording system 
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
eegInfo     = []; 
% eegInfo.coordsystem.EEGCoordinateSystem = 'Other'; 
% eegInfo.coordsystem.EEGCoordinateUnits = 'mm'; 
% eegInfo.coordsystem.EEGCoordinateSystemDescription = 'ALS with origin between ears, measured with Xensor.'; 

                                                   
% information about the motion recording system 
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
motionInfo  = []; 

tracking_systems                                    = {'ImpulseX2'}; 

% motion specific fields in json
motionInfo.motion = [];
motionInfo.motion.RecordingType                     = 'continuous';

% system 1 information
motionInfo.motion.TrackingSystems.(tracking_systems{1}).Manufacturer                     = 'PhaseSpace';
motionInfo.motion.TrackingSystems.(tracking_systems{1}).ManufacturersModelName           = 'ImpulseX2';
motionInfo.motion.TrackingSystems.(tracking_systems{1}).SamplingFrequencyNominal         = 'n/a';

% coordinate system
motionInfo.coordsystem.MotionCoordinateSystem      = 'RUF'; % for XYZ
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
subjectInfo.fields.group.Description    = 'experiment group';
subjectInfo.fields.group.Levels.young   = 'younger participants under 35';
subjectInfo.fields.group.Levels.old     = 'older participants over 65';
subjectInfo.fields.handedness.Description    = 'handedness of participant';
subjectInfo.fields.handedness.Levels.R   = 'right-handed';
subjectInfo.fields.handedness.Levels.L  = 'left-handed';

% names of the columns - 'nr' column is just the numerical IDs of subjects
%                         do not change the name of this column
subjectInfo.cols = {'nr',   'age',  'sex',  'group',    'handedness'};
subjectInfo.data = { 24,     30,     'F'     'young'     'R' ; ...
                     64,     71,     'F',    'old',      'R' ; ...
                     66,     67,     'M',    'old',      'R' ; ...
                     76,     34,     'M',    'young',    'R' ; };
                    


% loop over participants
for subject = [24,64,66,76]
   
    % loop over sessions 
    for session = 1:2
                
        config                        = [];                                 % reset for each loop 
        config.bids_target_folder     = '...\walking young and old\1_BIDS-data'; % required
        config.filename               = fullfile(['...\walking young and old\0_source-data\vp_' num2str(subject) '\vp_' num2str(subject) '_' sessionNames{session} '.xdf']); % required
        config.task                   = 'dualtask';                         % optional 
        config.subject                = subject;                            % required
        config.session                = sessionNames{session};              % optional
        config.overwrite              = 'on';
        
        config.eeg.stream_name        = 'BrainVision';                      % required

        
        config.motion.streams{1}.stream_name        = 'PhaseSpace_Rigid1';
        config.motion.streams{1}.tracking_system    = 'ImpulseX2';
        config.motion.streams{1}.tracked_points     = 'PhaseSpace_Rigid1';
        config.motion.streams{1}.tracked_points_anat= 'Head';

        config.motion.streams{2}.stream_name        = 'PhaseSpace_Rigid2';
        config.motion.streams{2}.tracking_system    = 'ImpulseX2';
        config.motion.streams{2}.tracked_points     = 'PhaseSpace_Rigid2';
        config.motion.streams{2}.tracked_points_anat= 'LeftThigh';

        config.motion.streams{3}.stream_name        = 'PhaseSpace_Rigid3';
        config.motion.streams{3}.tracking_system    = 'ImpulseX2';
        config.motion.streams{3}.tracked_points     = 'PhaseSpace_Rigid3';
        config.motion.streams{3}.tracked_points_anat= 'LeftLowerLeg';

        config.motion.streams{4}.stream_name        = 'PhaseSpace_Rigid4';
        config.motion.streams{4}.tracking_system    = 'ImpulseX2';
        config.motion.streams{4}.tracked_points     = 'PhaseSpace_Rigid4';
        config.motion.streams{4}.tracked_points_anat= 'LeftAnkle';

        config.motion.streams{5}.stream_name        = 'PhaseSpace_Rigid5';
        config.motion.streams{5}.tracking_system    = 'ImpulseX2';
        config.motion.streams{5}.tracked_points     = 'PhaseSpace_Rigid5';
        config.motion.streams{5}.tracked_points_anat= 'LeftForeFoot';

        config.motion.streams{6}.stream_name        = 'PhaseSpace_Rigid6';
        config.motion.streams{6}.tracking_system    = 'ImpulseX2';
        config.motion.streams{6}.tracked_points     = 'PhaseSpace_Rigid6';
        config.motion.streams{6}.tracked_points_anat= 'RightThigh';

        config.motion.streams{7}.stream_name        = 'PhaseSpace_Rigid7';
        config.motion.streams{7}.tracking_system    = 'ImpulseX2';
        config.motion.streams{7}.tracked_points     = 'PhaseSpace_Rigid7';
        config.motion.streams{7}.tracked_points_anat= 'RightLowerLeg';

        config.motion.streams{8}.stream_name        = 'PhaseSpace_Rigid8';
        config.motion.streams{8}.tracking_system    = 'ImpulseX2';
        config.motion.streams{8}.tracked_points     = 'PhaseSpace_Rigid8';
        config.motion.streams{8}.tracked_points_anat= 'RightAnkle';

        config.motion.streams{9}.stream_name        = 'PhaseSpace_Rigid9';
        config.motion.streams{9}.tracking_system    = 'ImpulseX2';
        config.motion.streams{9}.tracked_points     = 'PhaseSpace_Rigid9';
        config.motion.streams{9}.tracked_points_anat= 'RightForeFoot';
            

        config.motion.custom_function                   = 'bids_motionconvert_mobiworkshop';
        
        % config.phys.streams{1}.stream_name              = []; % optional in case phys streams are present
        config.overwrite = 'on'; 
        
        bemobil_xdf2bids(config, ...
            'general_metadata', generalInfo,...
            'participant_metadata', subjectInfo,...
            'motion_metadata', motionInfo, ...
            'eeg_metadata', eegInfo);
        
        
        % configuration for bemobil bids2set 
        %------------------------------------------------------------------
        config.study_folder         = studyFolder; 
%         bemobil_bids2set(config);
        
    end
    
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
    