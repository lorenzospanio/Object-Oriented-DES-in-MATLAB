classdef clients


    properties

        distribution
        parameters
        which_events_nonrandom
        schedule
        how_many_clients %%% I save how many clients and respectively how many completions 
        integer_min
        integer_max
        preference
        returning_queue %%% this is the direction is going after paying the server 
    end

    methods
        
        function obj = initialize_clients_arrivals_and_service_time(obj, distribution_arrivals, parameters_arrivals,...
                                                                        distribution_service_time, parameters_service_time,...
                                                                        which_events_nonrandom_arrivals,which_events_nonrandom_service,...
                                                                        schedule_arrivals, schedule_service,integer_min,integer_max,preference)
            %%% ARRIVALS                                                             
            obj.distribution = distribution_arrivals;
            obj.how_many_clients = length(obj.distribution);
            %%% attenzione che la proprietà distribution viene cambiata per
            %%% includere tutti 
            obj.distribution = {obj.distribution, distribution_service_time};
            obj.distribution = [obj.distribution{:}]; % to have them in single cells 


            obj.parameters = parameters_arrivals;
            obj.parameters = {obj.parameters,parameters_service_time};
            obj.parameters = [obj.parameters{:}];% to have them in single cells 

            obj.which_events_nonrandom = which_events_nonrandom_arrivals;
            obj.which_events_nonrandom = [obj.which_events_nonrandom, which_events_nonrandom_service];
            obj.schedule = schedule_arrivals;
            obj.schedule = [obj.schedule,schedule_service];
            
            obj.integer_min = integer_min;
            obj.integer_max = integer_max;

            obj.preference = preference;
        end


%%%%%%%%%%%% assuminamo per tutti uguale domanda ma facilmente estendibile 
        function number_of_items_asked = ask_items(obj)

            range = [obj.integer_min, obj.integer_max];
            number_of_items_asked =  randi(range);
        end




















    end
end