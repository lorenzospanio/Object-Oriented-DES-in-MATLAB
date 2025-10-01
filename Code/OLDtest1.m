clc
clear

rng(10);

%%% distribution for arrivals and service time and other kind of event 
mydiscrete_event = discrete_event();

%%%%%%%%%%%%%%%%%%%%% CLIENT MANAGER 
myclients = clients();

distribution_arrivals = {'Exponential', 'Normal','Exponential'};
parameters_arrivals = { {'mu', 6}, {'mu', 7, 'sigma', 0.5}, {'mu', 5}}; 

distribution_service_time = {'Normal','Exponential','Exponential'};
parameters_service_time = {{'mu', 3, 'sigma', 0.001},{'mu', 3}, {'mu', 1}};


which_events_nonrandom_arrivals =[0 0 0]; %%% so only random right now 
which_events_nonrandom_service = [0 0 0];
schedule_arrivals = [ 5 3 6 ]; % this is useless at the moment
schedule_service = [ 5 3 6 ]; % this is useless at the moment
integer_min = 5;
integer_max = 10;

myclients = myclients.initialize_clients_arrivals_and_service_time(distribution_arrivals,parameters_arrivals, distribution_service_time,parameters_service_time,...
    which_events_nonrandom_arrivals,which_events_nonrandom_service,schedule_arrivals,schedule_service,integer_min, integer_max);
%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%   SUPPLY MANAGER
distribution = {'Exponential', 'Normal','Exponential'};
parameters = { {'mu', 7}, {'mu', 9, 'sigma', 0.5}, {'mu', 8}};
which_events_nonrandom =[0 0 0]; %%% so only random right now 
schedule = [ 5 3 6 ]; % this is useless at the moment
mysupplyManager=supplyManager;
mysupplyManager = mysupplyManager.initialize_supply(distribution,parameters,which_events_nonrandom,schedule);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





lunghezza_transitorio = 100; 
myStatisticsManager=StatisticsManager;

max_serverd = 1100;
max_clock = 2000;
in_line = 0;
items = [100 100 100];
myStateManager=Future_event_Manager; 
myStateManager=myStateManager.initialization(mydiscrete_event, myclients,mysupplyManager, myStatisticsManager, max_serverd, max_clock, in_line,items);




% I initialize first the statemanager and then stats, IN THIS ORDER 

[myStatisticsManager, myStateManager] = myStatisticsManager.initialize_statistics(myStateManager, lunghezza_transitorio, {"busy","in_line"});

big_S = [100 100 100];
small_s = [50 70 30];
mypolicyOrder = policyOrder;
mypolicyOrder = mypolicyOrder.initialize_policy_s_S(big_S,small_s);

[myStateManager, myStatisticsManager]=myStateManager.start_simulation(mydiscrete_event,myclients,mysupplyManager,mypolicyOrder,myStatisticsManager);






