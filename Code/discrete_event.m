classdef discrete_event < EventManager


    properties



    end
    
    methods






        function handle_schedule(obj)
            A=zeros(len(obj.which_events_nonrandom),len(obj.which_events_nonrandom));
            A(logical(obj.which_events_nonrandom),:)=obj.schedule;
            obj.schedule=A; % now the schedule is correctly placed as a matrix 
        end



        function time = nextevent_random(obj, obj_clients, eventIndex)
            % Generates next event time for specified event using its distribution
            % eventIndex: Index of the event to process
            
            % Get distribution name and parameters for the specified event
            distName = obj_clients.distribution{eventIndex};
            params = obj_clients.parameters{eventIndex};
            
            % Convert parameters to name-value pairs
            if isstruct(params)
                paramFields = fieldnames(params);
                paramCell = cell(1, 2*numel(paramFields));
                for i = 1:numel(paramFields)
                    paramCell{2*i-1} = paramFields{i};
                    paramCell{2*i} = params.(paramFields{i});
                end
            elseif iscell(params)
                paramCell = params;
            else
                error('Event %d parameters must be struct or cell array', eventIndex);
            end
            
            %distribution object
            try
                pd = makedist(distName, paramCell{:});
            catch ME
                error('Failed creating "%s" for event %d: %s', distName, eventIndex, ME.message);
            end
            
            % Generate random time from this distribution
            time = random(pd);
        end
        



        function time = nextevent_deterministic(obj, obj_clients, eventIndex,objstat) %% here i must call the stat manager 
            time=obj_clients.schedule(eventIndex,objstat.events_count+1);%+1 because when resetting must star from 1 
        end




        function time = generating_time(obj, eventIndex,obj_clients, objstat)
            % depending of what kind of events it is, it can be extracted
            % from its random distribution or a partticular sequence
            
            if obj_clients.which_events_nonrandom(eventIndex)==0
                time = nextevent_random(obj, obj_clients, eventIndex);
            else
                time = nextevent_deterministic(obj,obj_clients, eventIndex, objstat);
                % it is necessary to import objstat because I need to
                % extract the next element of the sequence 
            end

          end

    



        
    end


end









