classdef supplyManager

    properties
        distribution
        parameters
        which_events_nonrandom
        schedule
        order_sent
       
    end

    methods
        function obj = initialize_supply(obj, distribution, parameters,which_events_nonrandom,schedule)
            
            obj.distribution = distribution;
            obj.parameters = parameters;
            obj.which_events_nonrandom = which_events_nonrandom;
            obj.schedule = schedule; 

            % here I'm assuming that at the beginning there is nothing to
            % order and the delivery of the items when they arrive happen
            % instantly 
            obj.order_sent = zeros(length(obj.distribution),1); % column vector 
        end




    end
end



