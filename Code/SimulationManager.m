classdef SimulationManager < handle
 
    
   
    properties %%%%%%(SetAccess = protected, GetAccess = protected)
        mydiscrete_event
        myclients
        mysupplyManager
        myStatisticsManager
        myStateManager
        mypolicyOrder 
        myconnectormanager
        cells_of_obj_stats
    end
    
    methods



        function obj = SimulationManager(discrete_event, clients, ...
                supplyManager, Future_event_Manager,StatisticsManager,policyOrder,connector)

            obj.mydiscrete_event = discrete_event;
            obj.myclients = clients;
            obj.mysupplyManager = supplyManager;
            obj.myStateManager = Future_event_Manager;
            obj.myStatisticsManager = StatisticsManager;
            obj.mypolicyOrder = policyOrder;
            obj.myconnectormanager =  connector;
            obj.cells_of_obj_stats = {};
        end



        function [obj, Allcustomers] = simulation_initialization(obj, distribution_arrivals, parameters_arrivals, distribution_service_time,parameters_service_time,which_events_nonrandom_arrivals,...
                which_events_nonrandom_service,schedule_arrivals, schedule_service,integer_min,integer_max,preference,... %% end of clients
                distribution,parameters,which_events_nonrandom,schedule, ...
                Allqueues,max_serverd,max_clock,items,lunghezza_transitorio,big_S,small_s)  

% distribution_arrivals = {'Exponential', 'Normal','Exponential'};
% parameters_arrivals = { {'mu', 6}, {'mu', 7, 'sigma', 0.5}, {'mu', 5}}; 
% distribution_service_time = {'Normal','Exponential','Exponential'};
% parameters_service_time = {{'mu', 3, 'sigma', 0.001},{'mu', 3}, {'mu', 1}};


% which_events_nonrandom_arrivals =[0 0 0]; %%% so only random right now 
% which_events_nonrandom_service = [0 0 0];
% schedule_arrivals = [ 5 3 6 ]; % this is useless at the moment
% schedule_service = [ 5 3 6 ]; % this is useless at the moment
% integer_min = 5;
% integer_max = 10;

obj.myclients = obj.myclients.initialize_clients_arrivals_and_service_time(distribution_arrivals,parameters_arrivals, distribution_service_time,parameters_service_time,...
    which_events_nonrandom_arrivals,which_events_nonrandom_service,schedule_arrivals,schedule_service,integer_min, integer_max,preference);
%%%%%%%%%%%%%%%%%%%


%%%%%%%%% SUPPLY MANAGER
%distribution = {'Exponential', 'Normal','Exponential'};
%parameters = { {'mu', 7}, {'mu', 9, 'sigma', 0.5}, {'mu', 8}};
%which_events_nonrandom =[0 0 0]; %%% so only random right now 
%schedule = [ 5 3 6 ]; % this is useless at the moment

obj.mysupplyManager=obj.mysupplyManager.initialize_supply(distribution,parameters,which_events_nonrandom,schedule);
%%%%%%%%%%%%%%%%%%%%

%%%%%%%STATE MANAGER
[obj.myStateManager, Allcustomers]=obj.myStateManager.initialization(obj.mydiscrete_event, obj.myclients,obj.mysupplyManager, obj.myStatisticsManager, Allqueues, max_serverd, max_clock, items);




[obj.myStatisticsManager,obj.myStateManager] = obj.myStatisticsManager.initialize_statistics(obj.myStateManager, lunghezza_transitorio, {"busy","in_line"},Allqueues);
obj.mypolicyOrder = obj.mypolicyOrder.initialize_policy_s_S(big_S,small_s);
   
        
 end

 function [obj,final_stats]=run_simulation(obj,number_of_simulations,distribution_arrivals, parameters_arrivals, distribution_service_time,parameters_service_time,which_events_nonrandom_arrivals,...
                which_events_nonrandom_service,schedule_arrivals, schedule_service,integer_min,integer_max,preference,... %% end of clients
                distribution,parameters,which_events_nonrandom,schedule, ...
                Allqueues,max_serverd,max_clock,items,lunghezza_transitorio,big_S,small_s)
                

     for k=1:number_of_simulations

        % initialize the simulation always in the same way 
        [obj,Allcustomers] = simulation_initialization(obj, distribution_arrivals, parameters_arrivals, distribution_service_time,parameters_service_time,which_events_nonrandom_arrivals,...
                which_events_nonrandom_service,schedule_arrivals, schedule_service,integer_min,integer_max,preference,... %% end of clients
                distribution,parameters,which_events_nonrandom,schedule, ...
                Allqueues,max_serverd,max_clock,items,lunghezza_transitorio,big_S,small_s); 
        % run the simulation
       
        [obj.myStateManager, obj.myStatisticsManager]=obj.myStateManager.start_simulation(obj.mydiscrete_event,obj.myclients,obj.mysupplyManager,obj.mypolicyOrder,obj.myStatisticsManager,Allqueues,Allcustomers,obj.myconnectormanager);
        % save the object 
        obj = obj.save_statistics();
 
     end

     final_stats = obj.average_all_the_simulations(number_of_simulations)
 
 end




 function obj = save_statistics(obj)
            
            obj.cells_of_obj_stats{end+1}=obj.myStatisticsManager;


 end




 function final_stats = average_all_the_simulations(obj,number_of_simulations)

    final_stats.average_events_count= zeros(obj.myStateManager.number_of_events,1);
    final_stats.clients_lost = zeros(1,obj.myStateManager.how_many_type_of_clients);
    % i build a matrix to save the average_waiting_time_clients for each
    % client 
    A=zeros(number_of_simulations,obj.myStateManager.how_many_type_of_clients);
    % the plus one is due to the fact that Confidence interval is a 2x1
    % vecor so it takes more space to store 
    final_stats.average_flow_time_clients_SIMULATIONS_confidene_interval=zeros(4,0);
     
    vector_average_flow_time_for_all = [];

    % I preallocate the matrix that contains all the values that have been
    % integrated

    final_stats.integration_ACROSS_SIMULATIONS_confidence_interval = zeros(4,0);
    B=zeros(number_of_simulations,length(obj.myStatisticsManager.integration));

     for i= 1:number_of_simulations

        final_stats.average_events_count= final_stats.average_events_count + obj.cells_of_obj_stats{i}.events_count;
        
        
        final_stats.clients_lost = final_stats.clients_lost + obj.cells_of_obj_stats{i}.clients_lost;
        
        % the same clients are now put on the same colums 
        A(i,:) = obj.cells_of_obj_stats{i}.average_flow_time_clients';

       vector_average_flow_time_for_all(i) = obj.cells_of_obj_stats{i}.average_flow_time_for_all;
        



            B(i,:) = obj.cells_of_obj_stats{i}.integration;




     end


final_stats.average_events_count = final_stats.average_events_count/number_of_simulations;

final_stats.clients_lost = final_stats.clients_lost/number_of_simulations;


%for average_waiting_time_clients
% for each column 
     for j = 1:size(A,2)
     [value, sigma, CI] = normfit(A(:,j));
     % now first row is the average time of each client, the second row the
     % sigma and the third and forth the intervals 
    final_stats.average_flow_time_clients_SIMULATIONS_confidene_interval(:,end+1) = [value;sigma;CI];
     end

    %I do the same but now it is just a vector 
    [value, sigma, CI] = normfit(vector_average_flow_time_for_all);
    final_stats.average_flow_time_for_all_SIMULATIONS_confidence_interval = [value; sigma; CI];

    for m = 1:size(B,2)
        [value, sigma, CI] = normfit(B(:,m));
        final_stats.integration_ACROSS_SIMULATIONS_confidence_interval(:,end+1) = [value; sigma; CI];
    end



 end




















    end
end