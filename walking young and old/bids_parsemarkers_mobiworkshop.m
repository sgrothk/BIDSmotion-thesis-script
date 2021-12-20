function [events, eventsjson] = bids_parsemarkers_mobiworkshop(events)
% default function does not parse markers
% enters zeros in duration fields and constructs a struct to be used in
% events.json 

% Author: Sein Jeung (seinjeung@gmail.com)

for iEvent = 1:numel(events)
    events(iEvent).duration = 0; 
end

% trialstart
% trialend
% buttonpress
% buttonrelease
% 


eventsjson.onset.Description = 'Onset of the event'; 
eventsjson.onset.Units       = 's'; 

eventsjson.duration.Description = 'Duration of the event'; 
eventsjson.duration.Units       = 's'; 

eventsjson.sample.Description = 'Sample index nearest to the onset of the event'; 
eventsjson.sample.Units       = 'sample'; 

eventsjson.type.Description     = 'Type of the event'; 
eventsjson.type.Levels.Markers  = 'Experiment marker'; 

eventsjson.value.Description     = 'Unparsed marker string'; 

end