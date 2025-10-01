classdef direction_connector < connector
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here

    properties
        
    end

    methods
        function [next_queue,Allqueues,customer] = next_queue_to_go(obj, customer, current_queue, Allqueues, obj_clients)

            switch customer.current_queue
                case 1 % ID of the queues 
                    [next_queue,Allqueues] = obj.condition_decide(customer,current_queue, Allqueues, obj_clients);

                case 2
                    next_queue = Allqueues{6}.ID;

                case 3 
                    next_queue = Allqueues{6}.ID;
                case 4
                    next_queue = Allqueues{6}.ID;
                case 5
                    next_queue = Allqueues{6}.ID;

                case 6
                        % I let the customer go back to where it was and
                        % signal that this is returning there
                        next_queue = Allqueues{customer.returning_to_queue}.ID;
                case 0
                    next_queue = NaN;

            
            end


        end

  




        function [new_queue,Allqueues] = condition_decide(obj,customer, current_queue, Allqueues, obj_clients)
            % The the client likes to go left so we first check the left
            % side 

            % this function implies that if all are full the clients don't
            % move to the next queue but theyy stay were they are 

            % I use the event registered to get the element needed to know
            % the preference 
          
            new_queue = [];
            already_entered = 0;
            index = customer.Type; % to decice the precerence
        
            if  obj_clients.preference(index) == 0 

                if Allqueues{2}.max_in_line > Allqueues{2}.in_line
                    % now check if the next one is free 
                    if (Allqueues{3}.max_in_line > Allqueues{3}.in_line)
                        
                        new_queue = Allqueues{3}.ID;
                        already_entered = 1;
                    else
                        % this is the case of the next one being occupied
                        
                        new_queue = Allqueues{2}.ID;
                        already_entered = 1;
                    end
                    
                end
    
    
    
                if Allqueues{4}.max_in_line > Allqueues{4}.in_line && already_entered == 0;

                    % now check if the next one is free 
                    if (Allqueues{5}.max_in_line > Allqueues{5}.in_line)
                        
                        new_queue = Allqueues{5}.ID;
                        
                    else
                        % this is the case of the next one being occupied
                        
                       
                        new_queue = Allqueues{4}.ID;
                        
                    end

                elseif isempty(new_queue)
                    % this is the case that the customer cant move because both of the queues are full 
                    % I put it here as the last resort that the customer has 
                    
                    new_queue = Allqueues{customer.current_queue}.successors; % this is the case of not having a next queue
                    Allqueues{customer.current_queue}.blocked = 1;
                end



            else %%% here I prefer right and so i check that one first 

                if Allqueues{4}.max_in_line > Allqueues{4}.in_line
                    % now check if the next one is free 
                    if (Allqueues{5}.max_in_line > Allqueues{5}.in_line)
                        
                        new_queue = Allqueues{5}.ID;
                        already_entered = 1;
                    else
                        % this is the case of the next one being occupied
                        
                       
                        new_queue = Allqueues{4}.ID;
                        already_entered = 1;
                    end
                    
                end

                if Allqueues{2}.max_in_line > Allqueues{2}.in_line && already_entered == 0
                    % now check if the next one is free 
                    if (Allqueues{3}.max_in_line > Allqueues{3}.in_line)
                        
                        new_queue = Allqueues{3}.ID;
                    else
                        % this is the case of the next one being occupied
                        
                        new_queue = Allqueues{2}.ID;
                    end


                elseif isempty(new_queue)
                    % this is the case that the customer cant move because both of the queues are full 
                    % I put it here as the last resort that the customer has 
                    
                    new_queue = Allqueues{customer.current_queue}.successors; % this is the case of not having a next queue
                    Allqueues{customer.current_queue}.blocked = 1;
                end
            

            end

    
  end






  function [queue_to_go_through ,Allqueues] = condition_decide_number2(obj,customer, current_queue, Allqueues, obj_clients)
    
    if customer.current_queue == 2
        queue_to_go_through = 3;

    elseif customer.current_queue == 4
        queue_to_go_through = 5;
    else
        queue_to_go_through = [];% this is to indicate the other cases 

    end



 end














    end
end