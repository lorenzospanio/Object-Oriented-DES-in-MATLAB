classdef EventManager < handle 
    
    %   This should be a generic class that must be able to capture all
    %   kinds of events possible in a discrete event simulation

    properties
        
    end

methods

    function [obj_state, obj_supply, obj_stat,Allqueues,Allcustomers] = event_is_arrival(obj, obj_state, obj_clients,obj_supply,obj_policy,obj_stat,Allqueues,Allcustomers,obj_connector)

     % this allows me to skip the next schedule if the arrival is not from the outside, but the movement is inside the queues        
     % here I give to the transfer the queue that we are currently arriving
            
            which_queue = Allqueues{1}.ID; % the arrival is only on the first one 
            
            %%% I schedule the next arrival right away:
            time_next_arrival = obj.generating_time(obj_state.current_event, obj_clients, obj_stat);
            inserting_the_event_time = obj_state.clock + time_next_arrival;
            % I dont put anything in the customer_id because i give the id
            % to the customer when it arrives 
            
            obj_state.customer_id = obj_state.customer_id + 1;  % the total number of customers that ARE GOING TO ENTER,not yet entered
            type = obj_state.current_event;
            arrivalTime = inserting_the_event_time;
            

            customer = Customer(obj_state.customer_id, type, arrivalTime,which_queue); % I save the data in the class 
            
            % I insert this customer with the others 
            Allcustomers{obj_state.customer_id} = customer;
            
            
            
            obj_state = obj_state.handle_list_of_events(inserting_the_event_time, obj_state.current_event,which_queue,obj_state.customer_id);

            % I record the arrival of the current event:
            obj_stat=obj_stat.record_arrival_times(obj_state); 
                


    
            % now that i handled the future arrival I deal with the current
            % one 

            
            

            current_queue = Allqueues{1}; % as stated before the first one is the arrival queue 
            % this next function deals with the movement of the new entry
            % in all the possible cases

            if Allqueues{1}.in_line < Allqueues{1}.max_in_line

                Allqueues{1}.in_line = Allqueues{1}.in_line + 1; 
                Allqueues{1}.vector_customers_id(end+1) = obj_state.current_ID;

                % if the id of the current state is the first I attempt to
                % move ( altrimenti sta in coda a non far nulla )
                if obj_state.current_ID == Allqueues{1}.vector_customers_id(1)
                    [Allqueues,customer,obj_state, obj_supply,obj_stat] = obj.AttemptMoveFromQueue(Allcustomers{obj_state.current_ID},current_queue,obj_state,obj_policy,Allqueues,Allcustomers,obj_clients,obj_stat,obj_connector,obj_supply);
                end
            
            else
                obj_stat.clients_lost(obj_state.current_event) = obj_stat.clients_lost(obj_state.current_event) + 1;
            end
               %%% HERE WE CAN USE THE ACCEPT REJECT??

        end











        function [obj_state,obj_supply,Allqueues,Allcustomers, obj_stat] = event_is_completing(obj,custormer,current_queue, obj_state,obj_clients,obj_supply, obj_policy, obj_stat, obj_connector, Allcustomers, Allqueues)

         

        index_customer = obj_state.current_ID;
        customer = Allcustomers{index_customer};
        current_queue = obj_state.current_queue;

        %%%%% I manually insert that if I'm at a pump I memorize 
        if Allqueues{current_queue}.type_of_queue == "petrol_station"
            customer.returning_to_queue = current_queue;
        elseif Allqueues{current_queue}.type_of_queue == "to_pay"
            customer.next_desired_queue = customer.returning_to_queue;
            customer.IsReturning = 1;
        end

        % I try to move the customer
        
        
        [obj_state,customer,current_queue,Allqueues,Allcustomers,obj_supply, obj_stat]= obj.condition_to_leave(obj_state,customer,current_queue,Allqueues,Allcustomers,obj_stat,obj_supply,obj_clients,obj_connector,obj_policy);

        % if the queue is not blocked I check the condition to exit of the
        % next in queue, if not satisfied I schedule the next one 

        % now I schedule the next event anyway because I either removed the
        % customer that wanted to leave or it didn't and it's a customer to
        % be served
        
        % attenzione che qui il customer è il primo della coda non quello
        % in output di prima 

        % ora se dietro quello che ho appena completato è presente un altro
        % lo schedulo subito ma solo se quello che è appena andato via ha
        % lasciato spazio, cioè non è andato nella direzione di pagare
        if ~isempty(Allqueues{current_queue}.vector_customers_id)  && Allqueues{current_queue}.blocked == 0
        new_customer_id = Allqueues{current_queue}.vector_customers_id(1);
        new_customer = Allcustomers{new_customer_id};

[obj,obj_state, obj_supply, obj_stat,Allqueues,Allcustomers]=obj.check_and_schedule_completion(new_customer,Allqueues{current_queue},obj_state,obj_policy,obj_stat,obj_supply,Allqueues,Allcustomers,obj_clients,obj_connector);
        
        end
        
        end






        function [obj_state,obj_supply, obj_stat] = event_is_of_other_kind(obj, obj_state, obj_supply, obj_stat)
                %%% obj_state.current_event is already
                %%% 2*how_many_type_of_clients
                %%%now check it is delivery of items 
                if obj_state.current_event <= 3*obj_state.how_many_type_of_clients
                    [obj_state,obj_supply, obj_stat] = obj.recive_supply(obj_state,obj_supply, obj_stat);
                end
            
           

        end

                                                                                              

            function [Allqueues,customer,obj_state, obj_supply,obj_stat]=AttemptMoveFromQueue(obj,customer,current_queue,obj_state,obj_policy,Allqueues,Allcustomers,obj_clients,obj_stat,obj_connector,obj_supply)
            % since current_queue.successors is used a lot i use another
            % variable as index to access the queue 
            
            
                % this is the case that the customer has payed and is going
                % back to the car and exiting
                

            
                % case: i have one destination and i can go there 
                
            if length(customer.next_desired_queue) == 1 && Allqueues{customer.next_desired_queue}.in_line < Allqueues{customer.next_desired_queue}.max_in_line
                
                
                
                if Allqueues{customer.next_desired_queue}.in_line == 0 && Allqueues{customer.next_desired_queue}.is_there_server == 0
                    % the next queue is also empty so I move on calling
                    % again the function 
                    [Allqueues,customer,obj_state, obj_supply,obj_stat]=obj.AttemptMoveFromQueue(customer,customer.next_desired_queue,obj_state,obj_policy,Allqueues,Allcustomers,obj_clients,obj_stat,obj_connector,obj_supply);
                elseif Allqueues{customer.next_desired_queue}.in_line ~= 0 && Allqueues{customer.next_desired_queue}.is_there_server == 0 
                    % this is the case of being able to move to a buffer 
                    current_queue.in_line = current_queue.in_line - 1;
                    Allqueues{customer.current_queue}.vector_customers_id(1) = []; % remove from the current queue 
                    if current_queue.in_line == 0
                        current_queue.busy = 0;
                    end
                    
                    Allqueues{customer.next_desired_queue}.in_line = Allqueues{customer.next_desired_queue}.in_line +1 ; 
                    Allqueues{customer.next_desired_queue}.vector_customers_id(end+1) = customer.ID; % I must save the order of the clients 
                    customer.current_queue = Allqueues{customer.next_desired_queue}; % I save in the customer that he has moved 
                
                
                    
                    
    
                elseif Allqueues{customer.next_desired_queue}.busy == 0
                    
                    % idle and not "to pay" queue 
                    % I schedule the completion in the successive queue

                    % If I have to move to to_pay I don't remove 
                    if Allqueues{customer.next_desired_queue}.type_of_queue ~= "to_pay"
                        % here 
                        Allqueues{customer.current_queue}.vector_customers_id(1) = [];
                        Allqueues{customer.current_queue}.in_line = Allqueues{customer.current_queue}.in_line -1;
                     elseif Allqueues{customer.next_desired_queue}.type_of_queue == "to_pay"
                        % this is the case of going to pay
                        Allqueues{customer.current_queue}.blocked = 1;  
                    end
                        
                      Allqueues{customer.next_desired_queue}.busy = 1;  
                      Allqueues{customer.next_desired_queue}.in_line = 1;
                      Allqueues{customer.next_desired_queue}.vector_customers_id(end+1) = customer.ID;
                      customer.current_queue = customer.next_desired_queue; % I save in the customer that he has moved 
                      


                        
                      [obj, obj_state, obj_supply, obj_stat,Allqueues,Allcustomers]=obj.check_and_schedule_completion(customer, Allqueues{customer.next_desired_queue}, obj_state,obj_policy, obj_stat,obj_supply,Allqueues,Allcustomers,obj_clients,obj_connector);
                         % this is to save the new desired queues once you
                          % moved 
                      
                      % qui metto questo controllo perchè se non ci sono abbastanza clienti se ne vanno e mettono NaN che crea problemi    
                      if ~isnan(customer.next_desired_queue) 
                        
                        [next_queue,Allqueues,customer] = obj_connector.next_queue_to_go(customer, customer.current_queue, Allqueues, obj_clients);
                        customer.next_desired_queue = next_queue;
                      end
                      
                      
                % and now I deal with the previous queue 
                %%%% this part is exactly the same for both the idle and
                %%%% busy part.
               
                    % I send the signal that there is now  a free place in
                    % the current queue 
                    
                  

                    % this part sends a signal to all the predecessors that
                    % are blocked, the first one that is blocked gets to
                    % move a customer forward

            % I send the signal back and remove the ID only if I'm not in
            % the special case of "to_pay"
            
            % di fatto questo codice non viene eseguito però per generalità
            % ha senso mandare dietro un segnale 
            % 
                    if Allqueues{customer.current_queue}.type_of_queue ~= "to_pay"
                        for i = current_queue.predecessors
                           
                                if Allqueues{i}.blocked == 1 
                                    % we transport from queue Allqueues{i} to the current
                                    % queue 
                                    Allqueues{i}.in_line = Allqueues{i}.in_line - 1;
                                
                                if Allqueues{i}.in_line == 0
                                    Allqueues{i}.blocked = 0;          
                                end

                                    current_queue.vector_customers_id(:,end+1) = Allqueues{i}.vector_customers_id(1);
                                    % now the customer that must be moved has
                                    % to update where it is 
                                    Allcustomers{Allqueues{i}.vector_customers_id(1)}.current_queue = current_queue;
                                    Allqueues{i}.vector_customers_id(1)= [];
                                    current_queue.in_line = current_queue.in_line +1;
                                    break 
                                end
                            end
                        if current_queue.in_line == 0
                            current_queue.busy = 0;
                        end

                   
                        
                    end

                elseif Allqueues{customer.next_desired_queue}.busy == 1 % busy

                    % If I have to move to to_pay I don't remove 
                    if Allqueues{customer.next_desired_queue}.type_of_queue ~= "to_pay"
                        Allqueues{customer.current_queue}.vector_customers_id(1) = [];
                        Allqueues{customer.current_queue}.in_line = Allqueues{customer.current_queue}.in_line -1;
                    elseif Allqueues{customer.next_desired_queue}.type_of_queue == "to_pay"
                        % this is the case of going to pay
                        Allqueues{customer.current_queue}.blocked = 1;

                    end   

                    % the next queue 
                    Allqueues{customer.next_desired_queue}.in_line = Allqueues{customer.next_desired_queue}.in_line +1;
                    Allqueues{customer.next_desired_queue}.vector_customers_id(end+1) = customer.ID; % I must save the order of the clients 
                    customer.current_queue = Allqueues{customer.next_desired_queue}.ID; % I save in the customer that he has moved 
                      
                    % this is to save the new desired queues depending on
                    % if i want to exit or not 
                      if customer.IsWaitingToExitPump == 0
                          [next_queue,Allqueues,customer] = obj_connector.next_queue_to_go(customer, current_queue, Allqueues, obj_clients);
                          customer.next_desired_queue = next_queue;
                      elseif customer.IsWaitingToExitPump == 1
                            [queue_to_go_through ,Allqueues] = obj_connector.condition_decide_number2(customer, current_queue, Allqueues, obj_clients);
                          customer.next_desired_queue = queue_to_go_through; 
                      end
                %%%% this part is exactly the same for both the idle and
                %%%% busy part.
                
                    if Allqueues{customer.current_queue}.type_of_queue ~= "to_pay"
                        for i = current_queue.predecessors
                       
                            if Allqueues{i}.blocked == 1 
                                % we transport from queue Allqueues{i} to the current
                                % queue 
                                Allqueues{i}.in_line = Allqueues{i}.in_line - 1;

                                if Allqueues{i}.in_line == 0
                                    Allqueues{i}.blocked = 0;          
                                 end
                                
                                current_queue.vector_customers_id(:,end+1) = Allqueues{i}.vector_customers_id(1);
                                % now the customer that must be moved has
                                % to update where it is 
                                Allcustomers{Allqueues{i}.vector_customers_id(1)}.current_queue = current_queue;
                                Allqueues{i}.vector_customers_id(1)= [];
                                current_queue.in_line = current_queue.in_line +1;
                                break 
                            end
                        end
                    if current_queue.in_line == 0
                        current_queue.busy = 0;
                    end
                 end
                    %%%%% if this is a completion event I check I want to
                    %%%%% schedule the next event but if it wants to leave
                    %%%%% I let him leave 



                end

            elseif length(customer.next_desired_queue) == 1 && (Allqueues{customer.next_desired_queue}.in_line == Allqueues{customer.next_desired_queue}.max_in_line) 
                    % this is the case that I have one direction but I'm
                    % stuck here
                    current_queue.blocked = 1;
             
            

            else 
                    % now I have multiple choices, I select the next
                    % queue to go to (before it was obvious because only one):
                    [next_queue,Allqueues,customer] = obj_connector.next_queue_to_go(customer, current_queue, Allqueues, obj_clients);

                    % I save the where in general it wants to go to so i
                    % can resume it later
                    
                    old_desired_queue = customer.next_desired_queue;
                    
                    customer.next_desired_queue = next_queue; %%% I ONLY KEEP THE ID 
                     
                    if ~isequal(customer.next_desired_queue, old_desired_queue)
                        [Allqueues,customer,obj_state, obj_supply,obj_stat]=obj.AttemptMoveFromQueue(customer,current_queue,obj_state,obj_policy,Allqueues,Allcustomers,obj_clients,obj_stat,obj_connector,obj_supply);
                    else
                        Allqueues{customer.current_queue}.blocked = 1;
                    end   
            




            end


        end







        function [obj_state,customer,current_queue,Allqueues,Allcustomers,obj_supply, obj_stat]= condition_to_leave(obj,obj_state,customer,current_queue,Allqueues,Allcustomers,obj_stat,obj_supply,obj_clients,obj_connector,obj_policy)
                % the event is completion
                
                if customer.IsReturning == 1 && obj_state.current_event == obj_state.how_many_type_of_clients + customer.Type 
                    % this is the direction that the customer has to go
                    % after is returning 
                    [queue_to_go_through ,Allqueues] = obj_connector.condition_decide_number2(customer, current_queue, Allqueues, obj_clients);

                        if isempty(queue_to_go_through)
                        % if this condition is satisfied I actually get out of the system rigth away
                        % queue_to_go_through empty means that we can leave immediately ( queue 3
                        % and 5)

                                % condition to leave, the customer must be returning and the
                                % current event is the finishing of the completion
                                    [obj_stat, obj_state] = obj_stat.update_stat(obj_state,customer);
                                
                                    %   ATTENZIONE CHE QUI CURRENT QUEUE
                                    %   SIGNIFICA SIA LA CODA ATTUALE MA
                                    %   ANCHE QUELLA DA DOVE PROVENGO SE
                                    %   SONO NELLA STAZIONE DI TO PAY

                                    if  customer.failed_to_receve == 0
                                        Allqueues{current_queue}.in_line = Allqueues{current_queue}.in_line - 1;
                                        Allqueues{current_queue}.vector_customers_id(1)= [];
                                    end
                                    
                                    % now I unblock the queue that I was in ( the
                                    % one that I was returning )
                                     Allqueues{customer.current_queue}.blocked = 0;
                                    
                                     if Allqueues{current_queue}.in_line == 0
                                        Allqueues{current_queue}.busy = 0;
                                     end

                                     % this is a way to elimite from the
                                     % CLIENTS FROM THE ORIGINAL STATION 
                                     
                                        Allqueues{customer.returning_to_queue}.in_line = Allqueues{customer.returning_to_queue}.in_line -1; % also the queue that it was parking
                                        Allqueues{customer.returning_to_queue}.vector_customers_id(1)= []; % I eliminate the id also in the queue that I was blocking 
                                     
                                    customer.current_queue = 0; % this is the index I give to indicate that a customer exited
                                    customer.next_desired_queue = NaN;
                                   
                                for i =  Allqueues{customer.returning_to_queue}.predecessors
                                    % this is a for loop but it actually stops the
                                    % first time that the if statement is true 
                                 
                                        if Allqueues{i}.blocked == 1 
                                            % we transport from queue Allqueues{i} to the current
                                            % queue 
                                            
                                            Allqueues{i}.in_line = Allqueues{i}.in_line - 1;
                                            % se è vuota significa che si è
                                            % sbloccata altrimenti c'è ancora gente
                                            % che aspetta 
        
                                            if Allqueues{i}.in_line == 0
                                                Allqueues{i}.blocked = 0;          
                                            end
                                            
                                            Allqueues{customer.returning_to_queue}.vector_customers_id(:,end+1) = Allqueues{i}.vector_customers_id(1);
                                            % now the customer that must be moved has
                                            % to update where it is 
                                            Allcustomers{Allqueues{i}.vector_customers_id(1)}.current_queue =  customer.returning_to_queue;
                                            Allqueues{i}.vector_customers_id(1)= [];
                                            Allqueues{customer.returning_to_queue}.in_line = Allqueues{customer.returning_to_queue}.in_line +1;
                                            break 
                                        end
                                    end
                                if Allqueues{customer.returning_to_queue}.in_line == 0
                                    Allqueues{customer.returning_to_queue}.busy = 0;
                                end
        
        
        
        
        
                            % if i successully move a customer i scheduele its
                            % completion
                                    if ~isempty(Allqueues{customer.returning_to_queue}.vector_customers_id)
                                    new_customer = Allcustomers{Allqueues{customer.returning_to_queue}.vector_customers_id(1)};
        
                                    [next_queue,Allqueues,customer] = obj_connector.next_queue_to_go(new_customer, current_queue, Allqueues, obj_clients);
                                    new_customer.next_desired_queue = next_queue;
                                    [obj,obj_state, obj_supply, obj_stat,Allqueues,Allcustomers]=obj.check_and_schedule_completion(new_customer,Allqueues{new_customer.current_queue},obj_state,obj_policy,obj_stat,obj_supply,Allqueues,Allcustomers,obj_clients,obj_connector);
                                    end

                        elseif Allqueues{queue_to_go_through}.in_line == 0
                            % if this condition is satisfied I actually get out of the system 
                
                            % THE CODE HERE IS EXACTLY THE SAME AS ABOVE
                            % BECAUSE IT IS READY TO EXIT GIVEN THAT IT HAS
                            % NOTHING IN FRONT THAT BLOKS THE EXIT
                            
                            % condition to leave, the customer must be returning and the
                                % current event is the finishing of the completion
                                    [obj_stat, obj_state] = obj_stat.update_stat(obj_state,customer);
                                
                                    
                                    Allqueues{current_queue}.in_line = Allqueues{current_queue}.in_line - 1;
                                    % now I unblock the queue that I was in ( the
                                    % one that I was returning )
                                     Allqueues{customer.returning_to_queue}.blocked = 0;
                                    
                                     if Allqueues{current_queue}.in_line == 0
                                        Allqueues{current_queue}.busy = 0;
                                    end
                                    Allqueues{customer.returning_to_queue}.in_line = Allqueues{customer.returning_to_queue}.in_line -1; % also the queue that it was parking
                                    Allqueues{customer.returning_to_queue}.vector_customers_id(1)= []; % I eliminate the id also in the queue that I was blocking 
                                    Allqueues{current_queue}.vector_customers_id(1)= [];
                                    customer.current_queue = 0; % this is the index I give to indicate that a customer exited
                                    customer.next_desired_queue = NaN;
                                    
                                for i =  Allqueues{customer.returning_to_queue}.predecessors
                                    % this is a for loop but it actually stops the
                                    % first time that the if statement is true 
                                 
                                        if Allqueues{i}.blocked == 1 
                                            % we transport from queue Allqueues{i} to the current
                                            % queue 
                                            
                                            Allqueues{i}.in_line = Allqueues{i}.in_line - 1;
                                            % se è vuota significa che si è
                                            % sbloccata altrimenti c'è ancora gente
                                            % che aspetta 
        
                                            if Allqueues{i}.in_line == 0
                                                Allqueues{i}.blocked = 0;          
                                            end
                                            
                                            Allqueues{customer.returning_to_queue}.vector_customers_id(:,end+1) = Allqueues{i}.vector_customers_id(1);
                                            % now the customer that must be moved has
                                            % to update where it is 
                                            Allcustomers{Allqueues{i}.vector_customers_id(1)}.current_queue =  customer.returning_to_queue;
                                            Allqueues{i}.vector_customers_id(1)= [];
                                            Allqueues{customer.returning_to_queue}.in_line = Allqueues{customer.returning_to_queue}.in_line +1;
                                            break 
                                        end
                                    end
                                if Allqueues{customer.returning_to_queue}.in_line == 0
                                    Allqueues{customer.returning_to_queue}.busy = 0;
                                end
        
        
        
        
        
                            % if i successully move a customer i scheduele its
                            % completion
                                    if ~isempty(Allqueues{customer.returning_to_queue}.vector_customers_id)
                                    new_customer = Allcustomers{Allqueues{customer.returning_to_queue}.vector_customers_id(1)};
        
                                    [next_queue,Allqueues,customer] = obj_connector.next_queue_to_go(new_customer, current_queue, Allqueues, obj_clients);
                                    new_customer.next_desired_queue = next_queue;
                                    [obj,obj_state, obj_supply, obj_stat,Allqueues,Allcustomers]=obj.check_and_schedule_completion(new_customer,Allqueues{new_customer.current_queue},obj_state,obj_policy,obj_stat,obj_supply,Allqueues,Allcustomers,obj_clients,obj_connector);
                                    end

                        
                        else  
                            % THIS IS THE CASE OF WANTING TO EXIT BUT BEING
                            % BLOCKED BY THE ONE IN FRONT 
                            % I PROGRAMMED SO THAT IF THE QUEUE IN FRONT IS
                            % NOT FULL WHEN I GET THE CHANCE I MOVE THERE
                            % AND INSTEAD OF BEING SCHEDULED A COMPLETION
                            % WHEN IT IS TIME THE CUSTOEMR EXITS THE SYSTEM
                            % 

                            % I elimitate form the current queue that the
                            % customer was in 
                            Allqueues{current_queue}.in_line = Allqueues{current_queue}.in_line - 1;
                            Allqueues{current_queue}.vector_customers_id(1)= [];        
                             if Allqueues{current_queue}.in_line == 0
                                   Allqueues{current_queue}.busy = 0;
                             end        
                              % here is the change of the customer waint to
                              % exit 
                              customer.IsWaitingToExitPump = 1;
                              customer.next_desired_queue = queue_to_go_through;
                              customer.current_queue = customer.returning_to_queue;
                              
                              %[Allqueues,customer,obj_state, obj_supply,obj_stat]=AttemptMoveFromQueue(obj,customer,current_queue,obj_state,obj_policy,Allqueues,Allcustomers,obj_clients,obj_stat,obj_connector,obj_supply)
                              [Allqueues,customer,obj_state, obj_supply,obj_stat]=obj.AttemptMoveFromQueue(customer,Allqueues{customer.current_queue},obj_state,obj_policy,Allqueues,Allcustomers,obj_clients,obj_stat,obj_connector,obj_supply);        
                                        
                        
                        
                        
                        end
                        
                        
                        
                        
               else

                    % Most of the time this is the actual line that is
                    % executed because before it is a check for exiting the
                    % system 
                    [Allqueues,customer,obj_state, obj_supply, obj_stat]=obj.AttemptMoveFromQueue(customer,Allqueues{current_queue},obj_state,obj_policy,Allqueues,Allcustomers,obj_clients,obj_stat,obj_connector,obj_supply);
                end
        end


                    

                    
        


    function [obj_state, obj_supply] = ordina_supply(obj,obj_state,obj_supply, obj_stat,how_much_to_order,index_item)
            % I sample from the correct distribution of the supply
            % I generate and insert in the list of events 
            time_to_arrive = obj.generating_time(index_item,obj_supply, obj_stat);
            inserting_the_event= obj_state.clock + time_to_arrive;

            % this is just a fast way to understand what kind of event it
            % is, if there are 3 clients, the first 3 are arrivals,the next
            % 3 are completion and the others are supply that corresponds
            % to the number of clients 

            % I PUT AS QUEUE 1 AND CUSTOMER 1 IN ORDER NOT TO GIVE ERROR,
            % IT'S ALL GOOD BECAUSE THESE INFORMATIONS ARE NOT USED
            obj_state = obj_state.handle_list_of_events(inserting_the_event, 2*obj_state.how_many_type_of_clients + index_item,1,1);          
            obj_supply.order_sent(index_item) = how_much_to_order;
    
    end


% this function must be called after the arrival of the 
        function [obj_state,obj_supply, obj_stat] = recive_supply(obj,obj_state,obj_supply, obj_stat)
            %%% the current event is the arrival of the supply
            index = obj_state.current_event - 2*obj_state.how_many_type_of_clients;
            obj_state.items(index) = obj_state.items(index)+ obj_supply.order_sent(index);
            obj_supply.order_sent(index) = 0;



        end

%%%%%%%%%%%%%%% da cambiare questa cosa aaaaaaaaaaaaaaaa
        function [obj, obj_state]=handle_if_not_enough_stuff_to_give(obj, obj_state)
                        obj_stat.list_of_arrival_of_clients(:,1) =[];
                        obj_state.in_line = length(obj_stat.list_of_arrival_of_clients(1,:));
                        
                        % since the event is for sure completion I subtrack
                        % how many clients and obtain the index of the
                        % client
                        index = obj_state.current_event - obj_state.how_many_type_of_clients;
                        obj_stat.clients_lost(index) = obj_stat.clients_lost(index)+1;
                        
                        % Use index_first_in_line (the client leaving) instead of current_event
                         if index_first_in_line > 0 && index_first_in_line <= length(obj_stat.clients_lost) % Safety check
                            obj_stat.clients_lost(index_first_in_line) = obj_stat.clients_lost(index_first_in_line)+1;
                         else
                             warning('EventManager:event_is_completing', 'Attempted to record lost client with invalid index: %d', index_first_in_line);
                         end
                         % If removing the client emptied the list, the server should become idle.
                        if isempty(obj_stat.list_of_arrival_of_clients) || size(obj_stat.list_of_arrival_of_clients, 2) == 0
                            obj_state.busy = 0; 
                            % Optional consistency check/fix for in_line if needed:
                            % if obj_state.in_line ~= 0
                            %    warning('Inconsistency: list empty, in_line is %d. Setting to 0.', obj_state.in_line);
                            %    obj_state.in_line = 0;
                            % end
                        end


        end


        function [obj_state,obj_supply, obj_stat]=ask_items_and_transport_once_competed(obj, obj_state,obj_clients,obj_supply,obj_policy, obj_stat, current_queue,obj_connector)
                requested = obj_clients.ask_items();
                        index_first_in_line = obj_state.current_queue.list_of_arrival_of_clients(2,1);
    
                    if obj_state.items(index_first_in_line)>= requested && ~isempty(obj_state.current_queue.list_of_arrival_of_clients)
                        obj_state.items(index_first_in_line) = obj_state.items(index_first_in_line) - requested;
                        time_complete_service = obj.generating_time(obj_state.how_many_type_of_clients + obj_state.current_queue.list_of_arrival_of_clients(2,1),obj_clients, obj_stat);
                        inserting_the_event= obj_state.clock + time_complete_service;
                        % since this is a completion and using the structure of
                        % the events:
                        index = obj_state.how_many_type_of_clients + index_first_in_line;
                        obj_state=obj_state.handle_list_of_events(inserting_the_event, index,current_queue); 
    

                        % I now give a signal to the previous queues that a
                        % spot has been liberated 
                        for i= 1:length(obj_state.current_queue.predecessors)
                            if obj_state.current_queue.predecessors(i).blocked == 1 
                                % we transport from queue i to the current
                                % queue 
                                obj_state.current_queue.predecessors(i).blocked = 0;% at least for the moment
                                obj_state.current_queue.predecessors(i).in_line = obj_state.current_queue.predecessors(i).in_line - 1;
                                obj_state.current_queue.vector_customers_id(:,end+1) = obj_state.current_queue.predecessors(i).vector_customers_id(1);
                                obj_state.current_queue.predecessors(i).vector_customers_id(1)= [];
                                break 
                            end
                        end
                        %%% now I have to decide if I want to order or not
                        %%% using the index of the first in line not the
                        %%% past one that is used for completion
                        [obj_state, obj_supply] = obj_policy.decide_if_to_order_policy_s_S(obj_state, obj_supply, obj, obj_stat,index_first_in_line);
    
                    else
                        % the client leaves and is removed from the line 
                        [obj, obj_state]=handle_if_not_enough_stuff_to_give(obj, obj_state)
                    end
                    
        

                end
        




    %%%%%%                                                                  
                        
    function [obj,obj_state, obj_supply, obj_stat,Allqueues,Allcustomers]=check_and_schedule_completion(obj,customer,current_queue,obj_state,obj_policy,obj_stat,obj_supply,Allqueues,Allcustomers,obj_clients,obj_connector)
                        
        
        
        switch current_queue.type_of_queue 
            case "petrol_station"
                                requested = obj_clients.ask_items();
                                index = customer.Type;
                                if obj_state.items(index)>= requested
                                    obj_state.items(index) = obj_state.items(index) - requested;
                                    time_complete_service = obj.generating_time(obj_state.how_many_type_of_clients + index,obj_clients, obj_stat);
                                    inserting_the_event= obj_state.clock + time_complete_service;
                                    % since we know the event is arrival we take
                                    % care of the structure: first the clients,
                                    % then completion then the supply 
                                    
                                    index_to_add=obj_state.how_many_type_of_clients + index; % this is the usual symmetry
                                    % the current queue is used
                                    obj_state = obj_state.handle_list_of_events(inserting_the_event,index_to_add,current_queue.ID,customer.ID);
        
                                     %%% now I have to decide if I want to order or
                                     %%% not after the first client
                                    [obj_state, obj_supply] = obj_policy.decide_if_to_order_policy_s_S(obj_state, obj_supply,obj, obj_stat,index);
                                elseif customer.IsWaitingToExitPump == 1
                                    % this is the case that the customer
                                    % has already paied and want to leave
                                    % but is blocked so it moves to the
                                    % next queue and waits there and when
                                    % it is his turn instead of scheduling
                                    % it leaves immediately 
                                    [obj_stat, obj_state] = obj_stat.update_stat(obj_state,customer);
                                    Allqueues{customer.current_queue}.in_line = Allqueues{customer.current_queue}.in_line - 1;
                                    Allqueues{customer.current_queue}.vector_customers_id(1)=[]; % I remove the ID of the customer
                                    Allcustomers{customer.ID}.current_queue = 0;
                                    Allcustomers{customer.ID}.next_desired_queue = NaN;




                                else
                                    
                                    % the client leaves because not enough
                                    % items. 
                                    
                                    % this is the next direction that the
                                    % customer wants to go to exit 
                                    
                                    % in order to make this function work i
                                    % change the state from arrival to
                                    % completion to enter the if statement
                                    % of this funtion. Practically this
                                    % should not change the dynamic of the
                                    % simulation i think.
                                    customer.IsReturning = 1;
                                    customer.IsWaitingToExitPump = 1;
                                    customer.failed_to_receve = 1;
                                    % I use this trick to make it work in
                                    % the condition to leave function 
                                    customer.returning_to_queue = customer.current_queue;
                                    % this is the change from arrival to
                                    % completion
                                    obj_state.current_event = obj_state.how_many_type_of_clients + customer.Type; 
                                    
                                    [obj_state,customer,current_queue,Allqueues,Allcustomers,obj_supply, obj_stat]= obj.condition_to_leave(obj_state,customer,current_queue.ID,Allqueues,Allcustomers,obj_stat,obj_supply,obj_clients,obj_connector,obj_policy);
           
                                    
                                    % I don't compute the flow time because
                                    % they have not completed the whole
                                    % circle and 
                                    
                                    obj_stat.clients_lost(customer.Type) = obj_stat.clients_lost(customer.Type)+1;
        
        
                                
                            end
            case "to_pay"
                index = customer.Type;
                time_complete_service = obj.generating_time(obj_state.how_many_type_of_clients + index,obj_clients, obj_stat);
                                    inserting_the_event= obj_state.clock + time_complete_service;
                                    % since we know the event is arrival we take
                                    % care of the structure: first the clients,
                                    % then completion then the supply 
                                    
                                    index_to_add=obj_state.how_many_type_of_clients + index;
                                    % the current queue is used
                                    obj_state = obj_state.handle_list_of_events(inserting_the_event,index_to_add,customer.current_queue,customer.ID);
            case "entrance"
                            [Allqueues,customer,obj_state, obj_supply,obj_stat]=obj.AttemptMoveFromQueue(customer,current_queue,obj_state,obj_policy,Allqueues,Allcustomers,obj_clients,obj_stat,obj_connector,obj_supply)
        end
    
end




    end

    methods (Abstract)
         handle_schedule(obj)
         nextevent_random(obj, eventIndex)
         nextevent_deterministic(obj, eventIndex,objstat)
         generating_time(obj, eventIndex,objstat)
    end



end







