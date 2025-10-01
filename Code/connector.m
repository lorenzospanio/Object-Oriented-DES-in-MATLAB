classdef connector


    properties
        probability_of_going
    end

    methods

        







    end
    methods (Abstract)
        next_queue_to_go(obj, current_queue, Allqueues, obj_clients)
        condition_decide(obj,customer, current_queue, Allqueues, obj_clients)
    end




    end



