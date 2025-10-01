% --- ValueContainer.m ---
classdef Valuecontainer < handle % Inherit from 'handle' to get reference behavior
    properties
        vector 
    end

    methods
        
        function obj = assignvector(obj, initialvector)
            if nargin > 0 % Allow creating with an initial value
                
                obj.vector = initialvector;
            end
        end

        function obj = append(obj, value)
            obj.vector(end+1) = value;
        end
    end
end
