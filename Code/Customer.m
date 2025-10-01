classdef Customer < handle 
    properties
        ID
        Type
        Preference
        ArrivalTimeSystem
        returning_to_queue
        IsReturning
        current_queue
        next_desired_queue
        IsWaitingToExitPump
        failed_to_receve 
    end

    methods
        % Constructor
        function obj = Customer(id, type, arrivalTime,current_queue)
            obj.ID = id;
            obj.Type = type;    
            obj.ArrivalTimeSystem = arrivalTime;
            % Initialize other properties to default values 
            obj.IsReturning = 0;
            obj.current_queue = current_queue;
            obj.IsWaitingToExitPump = 0; % be default 
            obj.failed_to_receve = 0;
        end

    end
end
