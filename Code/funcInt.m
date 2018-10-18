classdef funcInt < handle
    
    properties
        fx;
        bound;
        
        fDer;
        fInt;
    end
    
    methods
        function obj = funcInt(fx, boundaries)
            % >[ --> 0
            % ]< --> 1
            obj.fx = fx;
            obj.bound = boundaries;
        end        
        
        function ret = integrate(obj, intBound) 
            
            syms x u;
            
            flagLower  = (logical(obj.bound(1,:) <= intBound(1)))';
            flagHigher = (logical(obj.bound(1,:) >= intBound(1)))';            
            flagOnMargin = find((flagLower & flagHigher),1);
            
            if (~isempty(flagOnMargin))
                flagLower (flagOnMargin) = ~obj.bound(2, flagOnMargin);
                flagHigher(flagOnMargin) =  obj.bound(2, flagOnMargin);
            end
            
            indInterL = find(flagLower & circshift(flagHigher,-1));
            
            flagLower  = (logical(obj.bound(1,:) <= intBound(2)))';
            flagHigher = (logical(obj.bound(1,:) >= intBound(2)))';            
            flagOnMargin = find((flagLower & flagHigher),1);
            
            if (~isempty(flagOnMargin))
                flagLower (flagOnMargin) = ~obj.bound(2, flagOnMargin);
                flagHigher(flagOnMargin) =  obj.bound(2, flagOnMargin);
            end
            
            indInterH = find(flagLower & circshift(flagHigher,-1));
            
            obj.fInt = zeros(length(obj.bound(1,:)) - 1,1)';            
            obj.fInt(linspace(indInterL, indInterH, indInterH - indInterL + 1)) = 1;
            
            if indInterL ~= indInterH
                obj.fInt(indInterL) = int(obj.fx(indInterL), x, intBound(1), obj.bound(1, indInterL+1));
                obj.fInt(indInterH) = int(obj.fx(indInterH), x, obj.bound(1, indInterH), intBound(2));
            end
            
            if indInterL == indInterH
                obj.fInt(indInterL) = int(obj.fx(indInterH), x, intBound(1), intBound(2));
            end
            
            for i = indInterL + 1 : indInterH - 1
                obj.fInt(i) = int(obj.fx(i), x, obj.bound(1, i), obj.bound(1, i+1));
            end
            
            ret = double(sum(obj.fInt));
        end
    end
end

