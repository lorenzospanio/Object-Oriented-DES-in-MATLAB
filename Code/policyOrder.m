classdef policyOrder


    properties
        big_S % it is a vector of the same length oof the client and it contains how much I can store 
        small_s % soglia sotto cui ordino
    end

    methods

        function obj = initialize_policy_s_S(obj, big_S, small_s)
            obj.big_S = big_S;
            obj.small_s = small_s;
        end
               
        function [obj_state, obj_supply] = decide_if_to_order_policy_s_S(obj,obj_state, obj_supply, obj_discrete,obj_stat,index)

        % since this function will only be called aftter only the first arrival of a client
        % or 
        % the current event to understand what kind of client it is
        % this is the case of 
        
        % this is the case of completion so I change the index to the one
        % first in line
        

        % if the items go under s I send an order (and is not already sent)
        if obj_state.items(index) <= obj.small_s(index) && obj_supply.order_sent(index) == 0 

            how_much_to_order = obj.big_S(index) - obj_state.items(index);
            [obj_state, obj_supply] = obj_discrete.ordina_supply(obj_state,obj_supply, obj_stat, how_much_to_order,index);

        end
    end
    end





end