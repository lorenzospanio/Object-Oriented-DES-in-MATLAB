classdef StatisticsManager
    %UNTITLED7 Summary of this class goes here
    %   Detailed explanation goes here

    properties
        events_count % this is a vector that has for each entry the number of
                    %times that that event happened 
        events_count_clients % this counts the type of customers that exit the system            
        lunghezza_transitorio
        clients_lost
        customerCounter %%% this is the total amout of clients entered in the system

        cumulative_flow_time % this is a vector with the same size as the number of different clients 
        average_flow_time_clients
        average_flow_time_for_all 
        
        
        list_of_arrival_of_clients % this is a 2x1 matrix started empty so that I keep track of the clients waiting in 
                                    % queue, I keep track in order their
                                    % arrival time in the queue and in the
                                    % second row the index of which type of
                                    % client they are

        tracked_property_names % Cell array of strings: names of StateManager properties to integrate (e.g., {'busy', 'in_line'})
        num_tracked %% just the length of tracked_property_names

        past_clock_and_value % this is a 2xlength(list_of_properties_to_integrate) matrix that is built by columns
                                % and has for the first row the clock of
                                % the last update and as second row the
                                % value of the specific column that i want
                                % to integrate
        new_clock_and_value 
        integration %%% this is a vector that keeps track of all the variables to integrate 
         
        
                                        
    end
   



    methods


        function [obj,obj_state] = initialize_statistics(obj,obj_state, lunghezza_transitorio, tracked_property_names,Allqueues)
             

            obj.lunghezza_transitorio = lunghezza_transitorio;
            obj.clients_lost = zeros(1,obj_state.how_many_type_of_clients);
            obj.customerCounter = 0;
            % the next one is not really an assignment
            obj.events_count = zeros(obj_state.number_of_events,1);
            obj.events_count_clients = zeros(obj_state.how_many_type_of_clients,1);
            obj.cumulative_flow_time = zeros(obj_state.how_many_type_of_clients, 1); % tutti zeri in colonna by default 
            obj.average_flow_time_clients = zeros(obj_state.how_many_type_of_clients, 1);
            obj.average_flow_time_for_all = 0; % by default 
            obj.list_of_arrival_of_clients=zeros(2,0); % by default 

%%%%%%%%%%%%%%%%%%%%%%%%% QUESTA COSA DI SOTTO è SBAGLIATA PERCHè NON è
%%%%%%%%%%%%%%%%%%%%%%%%% POSSIBILE CHE SIA VUOTO 




            
            %%% To keep track off the state I first of all track all the necessary variables 
            
            obj.tracked_property_names = tracked_property_names; % at the moment it is a cell 

            % the properies for each line plus the items over time 
            obj.num_tracked = length(Allqueues)*length(obj.tracked_property_names) + obj_state.how_many_type_of_clients;


            %%%%%%%%% I initialize a PROPERTY OF THE STATE BECAUSE
            %%%%%%%%% OTHERWISE IT WOULD GIVE AN ERROR 
            a = obj_state.update_variables_for_integration(obj,Allqueues);
            obj_state.vector_update_state_for_integration = a.vector_update_state_for_integration;
            
            %%%% integration part:
            
            obj.past_clock_and_value = [zeros(1,obj.num_tracked); obj_state.vector_update_state_for_integration];
            %%%% this is a row vector of all zeros, as long as the numebr
            %%%% of variables that I have to integrate
            obj.integration = zeros(1,obj.num_tracked); 

        end







        %%%%%% attenzione che le statistiche in generale devono essere
        %%%%%% raccolte dopo un transitorio 
        function reset_count(obj)
            obj.events_count=zeros(len(obj.events_count),1);
        end
        




 %%%%%% this function just keeps track of which event just happened and
 %%%%%% storess in a vector 
        function obj = update_events_count(obj, obj_state) 
            if obj_state.clock >= obj.lunghezza_transitorio
                obj.events_count(obj_state.current_event,1)= obj.events_count(obj_state.current_event,1)+1;
            end
        end


% this functio must be called after the event: client arrival
        function obj=record_arrival_times(obj, obj_state)

            if obj_state.clock >= obj.lunghezza_transitorio
            obj.list_of_arrival_of_clients(:,end+1) = [obj_state.clock; obj_state.current_event];
            end
        end
        
% this function must be called when i complete the service of a client 
function [obj,obj_state] = update_stat(obj, obj_state,customer)
          if obj_state.clock >= obj.lunghezza_transitorio
            %before eliminating the element I save the statistics and
            %putting in the correct class of clients

            % I update the number of served in the system
            obj_state.n_served = obj_state.n_served + 1;
            obj.events_count_clients(customer.Type,1) = obj.events_count_clients(customer.Type,1) +1;
            % I update only if not empty 
            if ~isempty(obj.list_of_arrival_of_clients)
            flow_time = obj_state.clock - customer.ArrivalTimeSystem;
            
obj.cumulative_flow_time(customer.Type,1) = obj.cumulative_flow_time(customer.Type,1) + flow_time;
            

            end
          end
        end






%%%%% function for mean waiting time for each client 

    function obj = compute_statistics_at_end(obj, obj_state)
        % this function gives the mean of only the clients that have been
        % served. Those in line that are still waiting at the end they leave 
        % THIS IS A POSSIBLE FURTHER IMPLEMENTATION
        if obj_state.clock >= obj.lunghezza_transitorio
        obj = obj.mean_waiting_clients(obj_state);


        %%% now that the simulation is ending i want to computhe the final
        %%% rectangle for each of the variable that we want to integrate 

        for i = 1:obj.num_tracked
            % for each index I compute the last rectangle 
            obj = obj.integral_calculation(obj_state, i); % i is a number here 
        end

        %%% I now divide by the time the integrals
        obj.integration = obj.integration/(obj_state.clock-obj.lunghezza_transitorio); 

    end
    end




    function  obj= mean_waiting_clients(obj, obj_state)
        if obj_state.clock >= obj.lunghezza_transitorio

            % I first calculate the average for all the customers 
            obj.average_flow_time_for_all = sum(obj.cumulative_flow_time)/obj_state.n_served;
        
            % and then It is possible to calculate the average inside the single customers
            

            obj.average_flow_time_clients = obj.cumulative_flow_time./obj.events_count_clients;

        end
    end

        

        %%% this function must be used after the state update 
        function obj = check_if_variables_changed_after_update_state(obj, obj_state)
            if obj_state.clock >= obj.lunghezza_transitorio
           
           the_new_clock_vector = obj_state.clock*ones(1,obj.num_tracked);

           %%% I change for all the clock and the second row is changed
           %%% with the updated values 

           
           % I build the new values: 
            obj.new_clock_and_value = obj_state.vector_update_state_for_integration; % this is just a vector but with the next time I build the matrix 
            obj.new_clock_and_value = [the_new_clock_vector; obj.new_clock_and_value];

           index=[];
            for j = 1:obj.num_tracked
                if obj.past_clock_and_value(2,j) ~= obj.new_clock_and_value(2,j)
                    index(end+1) = j; % I add the index to be changes and updated
                end
            end

            for i = index %%% this is a vector of indexes 

                %%% now that i have the indexes i change one by one 
                %%% the integral of each 

                obj = obj.integral_calculation(obj_state, i); % index is a number here 


            end
            
             %%% I update all the columns that have been adjourned and not
             %%% the the ones that have not been changed because this way I
             %%% remember the clock that the last time that column was
             %%% adjourned 
            obj.past_clock_and_value(:, index) = obj.new_clock_and_value(:,index); 
        end
        end





        function obj = integral_calculation(obj, obj_state, index)
            if obj_state.clock >= obj.lunghezza_transitorio
            % after updating the clock i calculate the rectangular area
            % with base*hight ( index is a number here) 

                interval_actual_start_time = obj.past_clock_and_value(1,index);
                value_during_interval = obj.past_clock_and_value(2,index);
                interval_end_time = obj_state.clock;
    
            % Effective start of the portion of this interval that counts for statistics
            
                effective_start_for_stats = max(interval_actual_start_time, obj.lunghezza_transitorio);
    
            % the part of the interval we are interested in is valid 
                if interval_end_time > effective_start_for_stats
                    duration_for_stats = interval_end_time - effective_start_for_stats;
                    area = duration_for_stats * value_during_interval;
                    obj.integration(index) = obj.integration(index) + area;
                end
            end
        end


    




        function obj = update_mean(obj)

            waiting = (obj.nextevent - obj.clock) * obj.inventory;
            obj.mean_stat = (obj.waiting + waiting)/obj.clock;

        end



    end





end
