classdef Future_event_Manager < StateManager


    properties
        
    end

    methods
        function obj=schedule_events(obj, obj_discrete, obj_clients, objstat,event_type,which_queue,CustomerID)

            % I loop over all possible events AVAILABLE AT THE MOMENT and 
            % insert them all in the list_of_events in the correct order
            % obj.list_of_possible_events is not ordered but is not
            % important 

  
                
                time=obj_discrete.generating_time(event_type, obj_clients, objstat);
                new_time_event = obj.clock + time;
                
                obj=obj.handle_list_of_events(new_time_event, event_type,which_queue,CustomerID);
                
         


        end


        
%%%%%% this below function must be used every time i schedule an event 
    function obj=handle_list_of_events(obj,new_time_event,event_type,which_queue,CustomerID)
        % Find the index of the first element greater than the new_time_event
        if isempty(obj.list_of_events) || size(obj.list_of_events, 2) == 0
            % If the list is empty, initialize it with the new event
            
            obj.list_of_events = [new_time_event; event_type; which_queue; CustomerID];
        else
            %checking =cell2mat(obj.list_of_events(1,:));
            idx = find(obj.list_of_events(1,:) > new_time_event, 1);
        
            if isempty(idx)
                % If no element is greater append it at the end
                new_column= [new_time_event; event_type; which_queue;CustomerID];
                obj.list_of_events = [obj.list_of_events, new_column ];
            elseif size(obj.list_of_events,2) == 1
                % this is the condition if I just inserted the first event
                % and i want to insert the second one 


                % here i add the new event at the end and sort it to make
                % sure that it is in order 
                new_column= [new_time_event; event_type; which_queue; CustomerID];
                obj.list_of_events = [obj.list_of_events, new_column];
                [~, colPermutation] = sort(obj.list_of_events(1, :));
                obj.list_of_events = obj.list_of_events(:, colPermutation);

            else
                % Insert the element in position idx
                new_column= [new_time_event; event_type; which_queue;CustomerID];
                obj.list_of_events = [obj.list_of_events(:,1:idx-1), new_column, obj.list_of_events(:,idx:end)];
                
            end 

        end
    end





    end
end



