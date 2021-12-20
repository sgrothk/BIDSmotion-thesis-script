
function motionOut = bids_motionconvert_mobiworkshop(motionIn, objects, pi,si,di)
% This function deals with
%  - identifying position and orientation channels
%  - finding and filling missing values
%  - making irregular time stamps regular 
%  - matching of time stamps between streams of the same sampling rates
%    (currently all motion steams are modified to have matching sampling rates)
%
% Author: Sein Jeung (seinjeung@gmail.com)
% 
% See also util_quat2eul

% config.quaternionComponents   = {'D', 'A', 'B', 'C'}; 
% config.eulerComponents        = {}; % as in the stream 
% config.cartCoordinates        = {}; % as in the stream
% config.missingVal             = 0; 
% config.missingValFill         = ''; 
% config.posInterp              = ''; 
% config.oriInterp              = '';
% config.posExtrap              = '';
% config.oriExtrap              = ''; 

% your quaternion [q1,q2,q3,q4] components, in this order, where 
% q1 is the real component 
% q1, q2, q3 are the axial components 
quaternionComponents    = {'C','A','B','D'};

% your euler components 
% specify axis labels of q2, q3, q4 you have specified above, in this order.
% the output of conversion using 'util_quat2eul.m' will result in 
% rotation order of q4-q3-q2 (intrinsic)
eulerComponents         = {'z','x','y'}; 

% yourcartesian coordinates 
cartCoordinates         = {'X','Y','Z'};

% handling missing value (how tracking loss is represented in the stream)
missingval = 0; % what is the value that represents tracking loss in the stream?
posInterp = 'pchip'; % which interpolation method is to be used for filling missing values in position streams?
oriInterp = 'nearest'; % which interpolation method is to be used for filling missing values in orientation streams?
posExtrapVal = nan; % which values should be used outside of the time series?
oriExtrapVal = nan; % which values should be used outside of the time series?
commonInterp = 'pchip'; 
commonExtrapVal = nan; 

% resampling parameters

% use participant specific parameters  
if pi == 78 && si == 1 
   motionIn(6:7) = []; % for participant 78, these streams in session "stand" are empty    
end

% iterate over different objects 
%--------------------------------------------------------------------------
motionStreamAll    = cell(numel(motionIn), 1);

for iM = 1:numel(motionIn)
    motionStream            = motionIn{iM};
    labelsPre               = [motionStream.label];
    chantypesPre            = [motionStream.hdr.chantype];
    motionStream.label            = [];
    motionStream.hdr.label        = [];
    motionStream.hdr.chantype     = [];
    motionStream.hdr.chanunit     = [];
    
    dataPre                 = motionStream.trial{1};
    dataPost                = [];
    oi                      = 0;

    for ni = 1:numel(objects)
        
        % check first if the object exists at all and if not, skip
        if isempty(find(contains(labelsPre, [objects{ni} '_Rigid']),1))
            continue;
        else
            oi = oi + 1;
        end
        
        quaternionIndices = NaN(1,4);
        
        % Check the lines below for quaternion channel names
        for qi = 1:4
            quaternionIndices(qi) = find(contains(chantypesPre, ['Orientation' quaternionComponents{qi}]) & contains(labelsPre,[objects{ni} '_Rigid']));
           
        end
        
        cartIndices = NaN(1,3);
        
        % Check the lines below for position channel names
        for ci = 1:3
            cartIndices(ci) = find(contains(chantypesPre, ['Position' cartCoordinates{ci}]) & contains(labelsPre,[objects{ni} '_Rigid'] ));
        end
        
        % convert from quaternions to euler angles
        orientationInQuaternion    = dataPre(quaternionIndices,:)';
        orientationInEuler         = util_quat2eul(orientationInQuaternion);  % the BeMoBIL util script
        orientationInEuler         = orientationInEuler';
        position                   = dataPre(cartIndices,:);    
        

        % find and fill missing values
        occindices                  = find(position(1,:) == missingval);
        position(:,occindices)      = nan;
        orientationInEuler(:,occindices) = nan;
        position            = fillmissing(position', posInterp, 'EndValues', posExtrapVal)';
        orientationInEuler  = fillmissing(orientationInEuler', oriInterp, 'Endvalues', oriExtrapVal)';

        % unwrap euler angles
        orientationInEuler         = unwrap(orientationInEuler,[], 2);

        % concatenate the converted data
        dataPost                   = [dataPost; orientationInEuler; position];
        
        % enter channel information
        % iterate over euler components
        for ei = 1:3
            motionStream.label{6*(oi-1) + ei}                 = [objects{ni} '_eul_' eulerComponents{ei}];
            motionStream.hdr.label{6*(oi-1) + ei}             = [objects{ni} '_eul_' eulerComponents{ei}];
            motionStream.hdr.chantype{6*(oi-1) + ei}          = 'ORNT';
            motionStream.hdr.chanunit{6*(oi-1) + ei}          = 'rad';
        end
        
        % iterate over cartesian coordinates
        for ci = 1:3
            motionStream.label{6*(oi-1) + 3 + ci}                 = [objects{ni} '_cart_' lower(cartCoordinates{ci})];
            motionStream.hdr.label{6*(oi-1) + 3 + ci}             = [objects{ni} '_cart_' lower(cartCoordinates{ci})];
            motionStream.hdr.chantype{6*(oi-1) + 3 + ci}          = 'POS';
            motionStream.hdr.chanunit{6*(oi-1) + 3 + ci}          = 'm';
        end
        
    end


    % only include streams that have data from at least one object 
    if oi > 0 
        motionStream.trial{1}     = dataPost;
        motionStream.hdr.nChans   = numel(motionStream.hdr.chantype);
        motionStreamAll{iM}       = motionStream;
    end
    
end

%--------------------------------------------------------------------------
% find the one with the highest sampling rate
motionsrates = []; 

for iM = 1:numel(motionStreamAll)
    motionsrates(iM) = motionStreamAll{iM}.hdr.Fs; 
end

[~,maxind] = max(motionsrates);

% copy the header from the stream with max srate
keephdr             = motionStreamAll{maxind}.hdr;

% overwrite some fields in header with resampled information 
keephdr.nSamples            = size(motionStreamAll{maxind}.trial{1},2);
keephdr.FirstTimeStamp      = motionStreamAll{maxind}.time{1}(1);
lastTimeStamp               = motionStreamAll{maxind}.time{1}(end);
keephdr.Fs                  = keephdr.nSamples/(lastTimeStamp - keephdr.FirstTimeStamp);
keephdr.TimeStampPerSample  = (lastTimeStamp - keephdr.FirstTimeStamp)/keephdr.nSamples;

% construct evenly spaced time points
regularTime         = {linspace(keephdr.FirstTimeStamp, lastTimeStamp, (lastTimeStamp - keephdr.FirstTimeStamp)*keephdr.Fs)};

keephdr.nChans      = 0;
keephdr.label       = {};
keephdr.chantype    = {};
keephdr.chanunit    = {};

if numel(motionStreamAll)>1

    % resample all data structures, except the one with the max sampling rate
    % this will also align the time axes
    for i=1:numel(motionStreamAll)
        
        % append channel information to the header
        keephdr.nChans      = keephdr.nChans + motionStreamAll{i}.hdr.nChans;
        keephdr.label       = [keephdr.label;       motionStreamAll{i}.hdr.label];
        keephdr.chantype    = [keephdr.chantype;    motionStreamAll{i}.hdr.chantype];
        keephdr.chanunit    = [keephdr.chanunit;    motionStreamAll{i}.hdr.chanunit];
        
        % resample
        ft_notice('resampling %s', motionStreamAll{i}.hdr.orig.name);
        
        cfg                 = [];
        cfg.time            = regularTime;
        cfg.detrend         = 'no';
        cfg.method          = commonInterp;
        cfg.extrapval       = commonExtrapVal; 
        motionStreamAll{i}  = ft_struct2double(motionStreamAll{i});
        motionStreamResampled{i}  = ft_resampledata(cfg, motionStreamAll{i});
        end
    
    % append all data structures
    motionOut = ft_appenddata(cfg, motionStreamResampled{:});
    
    % modify some fields in the header
    motionOut.hdr = keephdr;
else
    % simply return the first and only one
    motionOut = motionStreamResampled{1};
end

% wrap all orientation channels back to [pi, -pi]
%--------------------------------------------------------------------------
% find orientation channels
for Ci = 1:numel(motionOut.label)
    if contains(motionOut.label{Ci}, '_eul_')
        motionOut.trial{1}(Ci,:) = wrapToPi(motionOut.trial{1}(Ci,:)); 
    end
end

end
