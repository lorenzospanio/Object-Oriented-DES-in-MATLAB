classdef queue


    properties
        ID
        in_line
        max_in_line
        type_of_queue
        is_there_server
        busy
        queue_to_exit
        blocked
        successors
        predecessors
        vector_customers_id % this keeps the order of arrival of the ids of the customers
    end

    methods
        function obj= initialization(obj, ID, max_in_line,type_of_queue,is_there_server)
            obj.ID = ID;
            obj.in_line = 0; % by default 
            obj.max_in_line = max_in_line;
            obj.type_of_queue = type_of_queue;
            obj.blocked = 0; % no queue is blocked 
            obj.busy=0; % by default
            obj.is_there_server = is_there_server;
        end


        
    end
end