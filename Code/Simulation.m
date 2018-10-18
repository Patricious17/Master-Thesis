classdef Simulation < handle
    
    properties        
        dT; % simulation discretisation time unit
        simT; % simulation time      
        numA; % number of agents in the simulation
        mainCount; % counter for main loop of simulation
        mastercount;
        au2cm;
        surrTemp;
        heat; % position of heaters
             %: PosX, PosY -> position of heaters
             %: sigma -> gaussian distribution sigma parameter
             %: temp -> temperature of heater
        
        mode;
        dS;
        pos;        
        sqA;
        event;
        countProbs;
        
    end
    
    methods
        %% constructor
        function obj = Simulation(numA,dT, simT, heatPos, heatTemp, sigma, au2cm, mode)
            obj.dT = dT;
            obj.simT = simT;
            obj.numA = numA;
            obj.mainCount = 1;
            obj.mastercount = 1;
            obj.au2cm = au2cm;
            obj.surrTemp = 20;
            obj.heat = struct ('PosX' , heatPos(:,1)./au2cm,... 
                               'PosY' , heatPos(:,2)./au2cm,...                               
                               'temp' , heatTemp,...
                               'sigma', sigma);
            obj.mode = mode;
                           
            obj.dS = struct('wait',  zeros(numA,1)); 
            
            if(mode == 1)
                dimX = 1; dimY = 1;
                
                for i = 1:numA
                    obj.event{i} = '0';
                end
                
                obj.sqA = struct('dimX'   ,dimX ,...
                                 'dimY'   ,dimY ,...
                                 'regnumX', 1   ,...
                                 'regnumY', 1   ,...
                                 'reg'    ,char('?'*ones(numA,1)));
                             
                obj.pos = struct('X', obj.sqA.dimX*rand(numA,1),...
                                 'Y', obj.sqA.dimY*rand(numA,1));
                             obj.countProbs = [];
                
                if (obj.mode == 1)
                    Pos2Regions(obj);
                end                
            end
        end
        
        function constructCountProbs(obj,PR)
            obj.countProbs = zeros(PR.params.nCell,1);
        end
                
        function Pos2Regions(obj)
            obj.sqA.reg(logical(obj.pos.X >= 0 & obj.pos.X <  1 & obj.pos.Y >= 0 & obj.pos.Y <  1)') = 'a';
            obj.sqA.reg(logical(obj.pos.X >= 1 & obj.pos.X <  2 & obj.pos.Y >= 0 & obj.pos.Y <  1)') = 'b';
            obj.sqA.reg(logical(obj.pos.X >= 2 & obj.pos.X <= 3 & obj.pos.Y >= 0 & obj.pos.Y <  1)') = 'c';
            obj.sqA.reg(logical(obj.pos.X >= 0 & obj.pos.X <  1 & obj.pos.Y >= 1 & obj.pos.Y <= 2)') = 'd';
            obj.sqA.reg(logical(obj.pos.X >= 1 & obj.pos.X <  2 & obj.pos.Y >= 1 & obj.pos.Y <= 2)') = 'e';
            obj.sqA.reg(logical(obj.pos.X >= 2 & obj.pos.X <= 3 & obj.pos.Y >= 1 & obj.pos.Y <= 2)') = 'f';
        end
        
        %% triggers event transitions based on guard conditions
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function DEventTrigger(obj,a,PR)
                        
        % check for new encounters          
            
            trig = zeros(1,obj.numA);
            
            for i = 1:obj.numA
                if any(sqrt((obj.pos.X([1:(i-1), (i+1):end]) - obj.pos.X(i)).^2 + (obj.pos.Y([1:(i-1), (i+1):end]) - obj.pos.Y(i)).^2) - a.aParams.pZoneR(i)/obj.au2cm < 0)
                    trig(i) = 1;
                end
            end
            
            trig = trig' & ~obj.dS.wait;
            trig = logical(trig);
            obj.dS.wait(trig) = 1;
            
        % check for wait timer triggering
            
            trig = ~trig & logical((a.cS.timer <= 0) & (obj.dS.wait == 1) ); % complement of trig is derived from code above
            obj.dS.wait(trig) = 0;
            
        % extracting bots that are non-stationary
            a.wanderers = logical(~obj.dS.wait);
            
            obj.calcCountProbs(PR)
        end
        
        function calcCountProbs(obj,PR)
            dist = sqrt((obj.pos.X - obj.heat.PosX).^2+(obj.pos.Y - obj.heat.PosY).^2);
            for i = 1:PR.params.nCell                
                flag = (dist > (i-1)*PR.params.d/obj.au2cm) & (dist < i*PR.params.d/obj.au2cm);
                obj.countProbs(i,1) = sum(flag)/obj.numA;
            end
            flag = dist > PR.params.nCell*PR.params.d/obj.au2cm;
            SpreadAtEnd = sum(flag);
            addIt = zeros(length(obj.countProbs),1);
            addIt(end-SpreadAtEnd:end,1) = 1/obj.numA;
            obj.countProbs = obj.countProbs + addIt;
            
        end
        
        %% evolution step of continuous variables (simple integration)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function ContinuousStep(obj,a)
            
        % solve for one time step            
        % timer is counting even for wanderer, but it's time is always a negative
        % value that represents time elapsed since being in 'wait' state
            a.cS.timer = a.cS.timer - obj.dT;
            
            obj.pos.X(a.wanderers) = obj.pos.X(a.wanderers) + a.cS.velX(a.wanderers)/obj.au2cm*obj.dT;
            obj.pos.Y(a.wanderers) = obj.pos.Y(a.wanderers) + a.cS.velY(a.wanderers)/obj.au2cm*obj.dT;
            
        % correct for board constraints
            obj.pos.X(logical(obj.pos.X < 0)) = 0;
            a.cS.angle(logical(obj.pos.X == 0)) = 0;
            obj.pos.X(logical(obj.pos.X > obj.sqA.dimX)) = obj.sqA.dimX;
            a.cS.angle(logical(obj.pos.X >= obj.sqA.dimX)) = pi;
            obj.pos.Y(logical(obj.pos.Y < 0)) = 0;
            a.cS.angle(logical(obj.pos.Y == 0)) = pi/2;
            obj.pos.Y(logical(obj.pos.Y > obj.sqA.dimY)) = obj.sqA.dimY;
            a.cS.angle(logical(obj.pos.Y >= obj.sqA.dimY)) = -pi/2;
        end
        
        
        %% maps temperature values and temperature gradients to positions
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        function Pos2Temp(obj,a)  
                                  
            gaussT = (obj.heat.temp(1) - obj.surrTemp) *...
                      gaussmf(sqrt(sum(abs([(obj.pos.X - obj.heat.PosX(1)),...
                                            (obj.pos.Y - obj.heat.PosY(1))]).^2,2)),...
                                    [obj.heat.sigma, 0]);                  
            
            a.senses.temp = obj.surrTemp + gaussT;
            
            a.senses.tempGradX = (-(obj.pos.X - obj.heat.PosX(1))./(obj.heat.sigma.^2)).*gaussT;            
            a.senses.tempGradY = (-(obj.pos.Y - obj.heat.PosY(1))./(obj.heat.sigma.^2)).*gaussT;
                                  
            for i = 2:length(obj.heat.temp)                       
                        
            gaussT = (obj.heat.temp(i) - obj.surrTemp) *...
                            gaussmf(norm([(obj.pos.X - obj.heat.PosX(i)),...
                                          (obj.pos.Y - obj.heat.PosY(i))
                                         ]),...
                                    [obj.heat.sigma, 0]);                  
            
            newTemp = obj.surrTemp + gaussT;
            
            a.senses.tempGradX =  a.senses.tempGradX + (-(obj.pos.X - obj.heat.PosX(i))./(obj.heat.sigma.^2)).*gaussT;            
            a.senses.tempGradY =  a.senses.tempGradY + (-(obj.pos.Y - obj.heat.PosY(i))./(obj.heat.sigma.^2)).*gaussT;
             
            maxFlag = logical(newTemp>a.senses.temp);
            a.senses.temp(maxFlag) = newTemp(maxFlag);
             
            end           
        end        
    end    
end

