rng(10)
clc
clear

%%%%clients
distribution_arrivals = {'Exponential', 'Normal','Exponential'};
parameters_arrivals = { {'mu', 5}, {'mu', 4, 'sigma', 0.5}, {'mu', 3}}; 

distribution_service_time = {'Normal','Exponential','Exponential'};
parameters_service_time = {{'mu', 3, 'sigma', 0.001},{'mu', 3}, {'mu', 1}};


which_events_nonrandom_arrivals =[0 0 0]; %%% so only random right now 
which_events_nonrandom_service = [0 0 0];
schedule_arrivals = [ 5 3 6 ]; % this is useless at the moment
schedule_service = [ 5 3 6 ]; % this is useless at the moment
integer_min = 5;
integer_max = 10;
preference = [1,0,1]; % row vector, 1 is the prefernce of the right pump, 0 of the left
%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%   SUPPLY MANAGER
distribution = {'Exponential', 'Normal','Exponential'};
parameters = { {'mu', 7}, {'mu', 9, 'sigma', 0.5}, {'mu', 8}};
which_events_nonrandom =[0 0 0]; %%% so only random right now 
schedule = [ 5 3 6 ]; % this is useless at the moment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%% STATE MANAGER
max_serverd = 150;
max_clock = 5000;
items = [100 100 100];
%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%% STATISTICS
lunghezza_transitorio = 50; 
%%%%%%%%%%

%%%%%%%%% POLICY 
big_S = [100 100 100];
small_s = [50 70 30];
%%%%%%%%%%%%%%%



%%%%%%%%%%%%%   QUEUES

queue = queue;

%entrance:
max_in_line = 4;
type_of_queue= "entrance";
is_there_server = 0;
entrance_petrol_queue1 = queue.initialization(1,max_in_line,type_of_queue,is_there_server);

% petrol first left 
max_in_line = 3;
type_of_queue= "petrol_station";
is_there_server = 1;
petrol_queue2 = queue.initialization(2,max_in_line,type_of_queue,is_there_server);
% petrol second left 
max_in_line = 3;
type_of_queue= "petrol_station";
is_there_server = 1;
petrol_queue3 = queue.initialization(3,max_in_line,type_of_queue,is_there_server);

%petrol first right 
max_in_line = 3;
type_of_queue= "petrol_station";
is_there_server = 1;
petrol_queue4 = queue.initialization(4,max_in_line,type_of_queue,is_there_server);

%petrol second right 
max_in_line = 3;
type_of_queue= "petrol_station";
is_there_server = 1;
petrol_queue5 = queue.initialization(5,max_in_line,type_of_queue,is_there_server);


% queue to the pay 
max_in_line = inf; % I have put the petrol in so the clients are forced to pay 
type_of_queue= "to_pay";
is_there_server = 1;
to_pay_queue6 = queue.initialization(6, max_in_line,type_of_queue, is_there_server);




%%%% now the successors and predecessors for all the queues:
entrance_petrol_queue1.successors = [petrol_queue2.ID, petrol_queue3.ID, petrol_queue4.ID, petrol_queue5.ID];
entrance_petrol_queue1.predecessors = [];

petrol_queue2.successors = [to_pay_queue6.ID];
petrol_queue2.predecessors= [entrance_petrol_queue1.ID];

petrol_queue3.successors = [to_pay_queue6.ID];
petrol_queue3.predecessors= [entrance_petrol_queue1.ID];

petrol_queue4.successors = [to_pay_queue6.ID];
petrol_queue4.predecessors= [entrance_petrol_queue1.ID];

petrol_queue5.successors = [to_pay_queue6.ID];
petrol_queue5.predecessors= [entrance_petrol_queue1.ID];

to_pay_queue6.successors = [petrol_queue2.ID,petrol_queue3.ID,petrol_queue4.ID,petrol_queue5.ID];
to_pay_queue6.predecessors = [petrol_queue2.ID,petrol_queue3.ID,petrol_queue4.ID,petrol_queue5.ID];

%%%%%% 


%%% attention all queues must be put here in order from 1 to the end. it
%%% it is a cell array cantaineing a queue for each index
Allqueues = {entrance_petrol_queue1, petrol_queue2,petrol_queue3,petrol_queue4,petrol_queue5,to_pay_queue6};





%%%
number_of_simulations = 10;
%%%

%%% connector 
connector = direction_connector();
%%%

SimulationManager = SimulationManager(discrete_event, clients, ...
                supplyManager, Future_event_Manager,StatisticsManager,policyOrder,connector);




[obj,final_stats] = SimulationManager.run_simulation(number_of_simulations,distribution_arrivals,parameters_arrivals, distribution_service_time,parameters_service_time,which_events_nonrandom_arrivals,which_events_nonrandom_service,...
                schedule_arrivals, schedule_service,integer_min,integer_max,preference...% this is for the clients
                ,distribution,parameters,which_events_nonrandom,schedule, ...%this is for supply
            Allqueues, ... % queues 
            max_serverd,max_clock,items,...%%% this is for state
            lunghezza_transitorio,big_S,small_s); %statistics);






