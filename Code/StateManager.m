classdef   StateManager < handle
    
    %   Detailed explanation goes here

    properties
        
        clock
        
        broken %%% is the server capable od doing something, boolean value (0 default)
        max_serverd
        max_clock
        
        number_of_events  
        how_many_type_of_clients %%% this is the number of different clients that 
                         %%% are present in the simulation and  
        n_served

        
        items % anche questo è un vettore che dice quanti elementi ho a disposizione    




        customer_id % this is an increasing value that keeps track of the number of customers that enters the system

        


      
        list_of_events %% this is actually a matrix formed this way:
                        %in the first row there is the list of clock events that the 
                        %the simulation will advance.
                        %the second row contains the index that keeps track
                        %of which events are scheduled 
                        

        list_of_possible_events % this is a vector containing the events that can happen 
                                % this can help in the generating part of
                                % the events


                                   
        current_event % this is the first event of the list_of_events(2,1) that is going to be processed 
                        % and removed from the list of future events 
        current_queue % this contains in which queue the current is happening 
        current_ID
        
        vector_update_state_for_integration % this vector contains the values of the state that need to be tracked                 
        simulation_time

    end

    methods
        
        function [obj, Allcustomers]= initialization(obj, obj_discrete, obj_clients,obj_supply, obj_stat, Allqueues, max_serverd, max_clock, items)
            
            obj.number_of_events = length(obj_clients.distribution) + length(obj_supply.distribution);
            obj.clock=0; % by default
            
            obj.broken = 0;% by default 
            
            obj.max_serverd = max_serverd;
            obj.max_clock = max_clock;
            
            obj.how_many_type_of_clients = obj_clients.how_many_clients;

            obj.n_served = 0; % counting all different kinds of people served
            
            
            obj.items = items;





            
            obj.list_of_events = zeros(3,0); %%% I initialize an emply matrix 


            %%% TO SEMPLIFY THE POSSIBLE EVENTS THAT CAN HAPPEN AT 
            %%%%  THE VERY BEGENNING ARE ONLY THE ARRIVALS and the break time   

            obj.list_of_possible_events = 1:obj.how_many_type_of_clients; 

            %%%% this part is the initialization of the statistics
            

            %%%%% now generate the first events (all arrivals for the
            %%%%% moment)

            which_queue = Allqueues{1}.ID; % this first is the only queue of arrival 
            
            % now I generate the first scheduled arrival for all the
            % clients 

            for i = 1 : obj.how_many_type_of_clients
                obj=obj.schedule_events(obj_discrete, obj_clients, obj_stat,i,which_queue,i); % I give all ids of 0 because their true ID are assigned when arriving  
                
            end

            for j= 1 : obj.how_many_type_of_clients
                customer = Customer(j, j, obj.list_of_events(1,j),which_queue); % I save the data in the class 
            
                % I insert this customer with the others 
                Allcustomers{j} = customer;
            end
            

            obj.customer_id = obj.how_many_type_of_clients ; % so that I now can update it at each arrival 




  
        end

        function [obj, obj_stat,Allqueues,Allcustomers] = start_simulation(obj,obj_discrete,obj_myclients,obj_supply,obj_policy, obj_stat,Allqueues,Allcustomers,obj_connector)
        


            tic
            
            while obj.clock <= obj.max_clock && obj.n_served < obj.max_serverd
                % while one of the two conditions are not met keep looping
    
                % starting a new iteration:
                
                

                obj.current_event = obj.list_of_events(2,1); % save the currect event
                obj.current_queue = obj.list_of_events(3,1); % save the currect queue
                obj.current_ID = obj.list_of_events(4,1); % save the currect ID 

                obj.clock = obj.list_of_events(1,1); %% advance the clock 
                obj.list_of_events(:,1) = []; % QUESTO DEVE ESSERE MODIFICATO IN FUTURO 
               
                % checking the termination condition advancing clock, 
                % just in case the event itself triggered it.

                   %clock_cell_to_num = cell2mat(obj.clock); % it gives some weird error
                    if obj.clock > obj.max_clock || obj.n_served >= obj.max_serverd
                        
                         disp('Simulation end condition reached after event processing.');
                         break; % Exit the while loop
                    end
                %a = 111111111111111
                %current=obj.current_event
                %coda=obj.in_line
                %obj.list_of_events
                
                
                 [obj,obj_supply, obj_stat,Allqueues,Allcustomers] = obj.update_state(Allcustomers{obj.current_ID},Allqueues{obj.current_queue},obj_discrete,obj_myclients,obj_supply,obj_policy, obj_stat,Allqueues,Allcustomers,obj_connector);  %Here I update thee state
                
                
                % now I update the variables that i need to integrate that the
                % state may have changed 
                obj = update_variables_for_integration(obj, obj_stat,Allqueues);
    
                % now if the variables changed I update the integral and change
                % the old ones with the current values 
                obj_stat = obj_stat.check_if_variables_changed_after_update_state(obj);
                
                
                 % I now update what kind of event happened ( forse deve essere
                 % spostato prima di fare l'update dello stato 
                
                 obj_stat = obj_stat.update_events_count(obj);
    
                 % check if the exit conditions are met ater updating the state
                 if obj.n_served >= obj.max_serverd
                             disp('Simulation end condition reached after state update.');
                             break; % Exit the while loop
                  end
    
            end % end of the while loop

     obj_stat = obj_stat.compute_statistics_at_end(obj);  
     obj.simulation_time = toc;
     disp('Simulation loop finished.');
     disp('Final state:');
     obj  
     obj_stat            
            
   end % End of run_simulation method


   function obj = update_variables_for_integration(obj, obj_stat,Allqueues)

            obj.vector_update_state_for_integration = [];
     % now for all the queues I keep track of the desired properties
     % ("busy","in_line") for all of them 
        for s = 1:length(Allqueues)
            for i = 1:length(obj_stat.tracked_property_names)
                prop_name = obj_stat.tracked_property_names{i};
                prop_value = Allqueues{s}.(prop_name);

                % Store the retrieved value in 'obj' (caller's obj_state)
                obj.vector_update_state_for_integration(end+1) = prop_value;
            end
        end
            % now I deal with the items 
            for j = 1:obj.how_many_type_of_clients
                obj.vector_update_state_for_integration(end+1) = obj.items(j);
            end

   end



    function obj=accept_reject_client(obj)
            % this function checks the state of the queue and the client is
            % accepted or rejected

    end

    function obj=handle_priority(obj)
        %this function must be able to handle the priority of the clients
        %changing the list of events 


    end



    function obj=leave_the_queue(obj, objstat)
        %this is a function that allows the clients to leave after a while,
        %so it access the statistics and if someone waits too much itevent_is_arrival
        %leaves 

    end


    % IN THIS FUNCTIO WE CAN USE CURRENT EVENT THAT HAPPENED AND THE TIME 
    % THAT THIS EVENT HAPPENED (IT MAY BE USEFUL IN REALITY) 
    
    function [obj,obj_supply, obj_stat,Allqueues,Allcustomers] = update_state(obj,custormer,current_queue, obj_discrete,obj_clients, obj_supply,obj_policy, obj_stat,Allqueues,Allcustomers,obj_connector)
                    %check = cell2mat(obj.current_event);
                if  obj.current_event<= obj.how_many_type_of_clients
                    % I separate the arrivals from the completing of a
                    % service 
                    
                    
                    [obj_state, obj_supply, obj_stat,Allqueues,Allcustomers] = obj_discrete.event_is_arrival(obj, obj_clients,obj_supply,obj_policy, obj_stat,Allqueues,Allcustomers,obj_connector);
                    
                    
                elseif (obj.how_many_type_of_clients < obj.current_event) && (obj.current_event <= 2*obj.how_many_type_of_clients)
                        % the above line is useful because it reated the
                        % structure that after obj.how_many_type_of_clients
                        % arrivals there are as many times for servings 
                        
                        
                        [obj_state,obj_supply,Allqueues,Allcustomers, obj_stat] = obj_discrete.event_is_completing(custormer,current_queue, obj,obj_clients,obj_supply, obj_policy, obj_stat, obj_connector, Allcustomers, Allqueues);
                        
                else
                        % THIS IS ACTUALLY AN EMPTY FUNCTION SO FAR 
                        [obj,obj_supply, obj_stat]= obj_discrete.event_is_of_other_kind(obj,obj_supply, obj_stat);

                end

        end


    end



%%%%% both of these can be found in the subclass Future_event_Manager
    methods (Abstract)
         schedule_events(obj,obj_discrete, objstat)
         handle_list_of_events(obj,new_time_event,event_type)
    end







    end
 
    
  







