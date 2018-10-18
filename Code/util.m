classdef util < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        lPF;
    end
    
    methods
        
        function obj = util()
            
            obj.lPF =struct('fKoef', 1,...
                             'bKoef', 1,...
                             'mKoef', 1,...
                              'frw' , 1,...
                              'bcw' , 1);
            
        end        
        
        function [ rArr ] = LPF(obj,Arr)
            
            blur      = 1/10*ones(10,1);
            
            
            forward1  = [Arr(2:end);0];
            forward2  = [Arr(3:end);0;0];
            backward1 = [0; Arr(1:end-1)];
            backward2 = [0; 0; Arr(1:end-2)];
            
%             fKoef = (1/3) * ones(length(forward1 ), 1); fKoef(1  ,1) = 1/2;
%             bKoef = (1/3) * ones(length(backward1), 1); bKoef(end,1) = 1/2;
%             mKoef = (1/3) * ones(length(Arr      ), 1);

            rArr = 0.3*(backward2 + forward2) + 0.3*(backward1 + forward1) + 0.3.*Arr;
        end
        
        
    end
    
    

    
end

