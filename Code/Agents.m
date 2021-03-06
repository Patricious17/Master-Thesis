classdef Agents < handle
    
    properties
        numA;
        
        cS; % continuous variables        
        
        aParams; % parameters
        %: rW     -> random walk parameters
        %: pZone  -> bee's private zone
        %: tReset -> waiting time
        %: tGrad  -> an agent will tend to gravitate towards warmer spots,
        %            which is why temperature gradient is used in velocity 
        %            direction calculation
        %: alpha  -> factor that describes how dominant is temperature
        %            gradient relative to random walk in choosing direction 
        %: stdVel -> standard velocity of bee in the arena        
        
        senses;  % structure that holds numerical
                 % representations of sensed physical quantities.
                 % For the sake of simplicity or in some cases necessity of
                 % having normalized range of sensed quantities, the
                 % numerical representation of the sensed physical quantity
                 % does not necessarily have the value which represents 
                 % that specific quantity in corresponding SI units.
        %: temp   -> temperature at agent's current position
        %: tempGrad
        
        cogParams; % cognitive parameters ->  structure encompasses every 
                   % parameter related to functions that describe how
                   % an agent (bee) makes decision based on perception 
                   % or based on some internal triggering (timer triggering)
        %: W, expA, maxWait -> parameters of function which describes how                      
        %                      propensity of an agent to wait longer at the
        %                      location of encounter depends on the 
        %                      temperature at that same location
        
        wanderers; % flag vector that identifies non-stationary agents
        
        phiT;
        phiR;
        gradNorm;
        
    end
    
    methods
        
        %% constructor
        %%%%%%%%%%%%%%
        function obj = Agents(numA,var)
            
            obj.numA = numA;
            obj.phiT;
            obj.phiR;
            obj.gradNorm;
            
            obj.cS = struct('velX' ,  zeros(numA,1) ,...
                            'velY' ,  zeros(numA,1) ,...
                            'timer',  zeros(numA,1) ,...
                            'angle',  2*pi*(rand(numA,1) - 0.5));                        
            
            rW = struct('X', zeros(numA,1),...
                        'Y', ones(numA,1),...
                        'angle', pi/2*ones(numA,1));                      
            
            obj.aParams = struct('pZoneR',   0.5*ones(numA,1),...
                                 'tReset',    0.5*ones(numA,1) ,...
                                 'stdVel',           2.5       ,...                                 
                                 'rW'  ,            rW         ,...                                 
                                 'alpha',     0.1*ones(numA,1) ,...
                                 'angleRange',     pi*0.5);
            
            obj.cogParams = struct('expA', 0.6,...                                   
                                   'maxWait', 5); % seconds
            
            tGrad = struct('X', zeros(numA,1),...
                           'Y', ones(numA,1)); 
                       
                       
            obj.senses = struct ('temp', 20*ones(numA,1)  ,...
                                 'tGrad',    tGrad        ,...
                                 'tempGradX', ones(numA,1),...
                                 'tempGradY', ones(numA,1));
        end
        
        %% CogProc (Cognitive Processing) does mapping of collected
        %% sensors' data into decisions like orientation, velocity,
        %% waiting time,...
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function CogProc(obj,s)                       
            
        % calculate contribution of random walk
            obj.RandomWalk();             
        % calculate contribution of temperature gradient    
            obj.TGradient();
        % calculate alpha (ratio of contributions from gradient and RW)
            obj.CalcAlpha();
        % calculate velocity of moving agents
            obj.CalcVel();       
        % calculate waiting time            
            trig = logical((obj.cS.timer <= 0) & (s.dS.wait == 1));
            obj.CalcWait(trig);
            obj.cS.timer(trig) = obj.aParams.tReset(trig);
        end
             
        function RandomWalk(obj)
            randAngle = normrnd(0, obj.aParams.angleRange, obj.numA,1);
            %randAngle = 2*pi*(0.5 - rand(obj.numA,1));                              
            obj.aParams.rW.angle = randAngle;
            %obj.aParams.rW.X = cos(randAngle);
            %obj.aParams.rW.Y = sin(randAngle);            
        end      
        
        function TGradient(obj)
            obj.senses.tGrad.X = obj.senses.tempGradX;
            obj.senses.tGrad.Y = obj.senses.tempGradY;
        end
        
        function CalcAlpha(obj)
            %obj.aParams.alpha(obj.wanderers) = 0.2;                          
                
%%
%              obj.aParams.alpha(obj.wanderers) =  ...
%                 (exp(2 .* ...
%                       (obj.senses.temp(obj.wanderers) - obj.surrTemp) ...
%                       ./ ...
%                       (obj.aParams.idealTemp - obj.surrTemp) ...
%                     ) - 1 ...
%                 )  ...
%                 ./ ...
%                 (exp(2) - 1);      
            
        end            
        
        function CalcVel(obj)
            obj.gradNorm = (sqrt(sum(abs([obj.senses.tGrad.X,...
                                      obj.senses.tGrad.Y]).^2,2)));
            
            flag1 = logical(obj.wanderers & logical(obj.gradNorm >  0.001));
            flag2 = logical(obj.wanderers & logical(obj.gradNorm <= 0.001)); 
            
            if(~all(~flag1))
                obj.calcPhiAlpha(flag1);            
            end            
                       
            if(~all(~flag2))
                obj.calcPhiNAlpha(flag2);
            end
            
            obj.Map2range
            
            obj.cS.velX( obj.wanderers) = obj.aParams.stdVel.*cos(obj.cS.angle(obj.wanderers)); obj.cS.velX(~obj.wanderers) = 0;
            obj.cS.velY( obj.wanderers) = obj.aParams.stdVel.*sin(obj.cS.angle(obj.wanderers)); obj.cS.velY(~obj.wanderers) = 0;
        end 
        
        function calcPhiAlpha(obj, flag)
            obj.phiR = obj.aParams.rW.angle(flag);            
            obj.phiT = atan2(obj.senses.tGrad.Y(flag)./obj.gradNorm(flag), obj.senses.tGrad.X(flag)./obj.gradNorm(flag)) - obj.cS.angle(flag);
            obj.UseMinAng;            
            dphi1 = obj.aParams.alpha(flag) .* obj.phiT + (1 - obj.aParams.alpha(flag)) .* obj.phiR;
                        
            obj.cS.angle(flag) = obj.cS.angle(flag) + dphi1;
        end
        
        function calcPhiNAlpha(obj, flag)
            dphi2 = obj.aParams.rW.angle(flag);
            
            obj.cS.angle(flag) = obj.cS.angle(flag) + dphi2;            
        end
        
        function UseMinAng(obj)
            flagSign = sign(obj.phiT);            
            flagMinAP = abs(obj.phiT) > abs(obj.phiT - flagSign*2*pi);
            obj.phiT(flagMinAP) = obj.phiT(flagMinAP) - flagSign(flagMinAP)*2*pi; 
        end
        
        function Map2range(obj)
            flag = logical(obj.cS.angle > pi) & logical(obj.cS.angle < -pi);
            obj.cS.angle(flag) = obj.cS.angle(flag) - 2*pi*ceil(floor(obj.cS.angle(flag)./pi)./2);          
        end
       
        %% determination of wait time
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function CalcWait(obj, trig)            
            obj.aParams.tReset(trig) = obj.Fwait(obj.cogParams.maxWait, obj.cogParams.expA, obj.senses.temp(trig));
            %exponential function is normalized in a way that ideal temperature for bees (36 �C) yields the longest waiting time
        end
        
        function ret = Fwait(obj, mWait, expA, tempArr)
            ret = mWait*(exp(expA*tempArr)-1)./(exp(expA*36)-1);
        end
        
        %% sensing enviromental signals
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Sense(obj,s)
            s.Pos2Temp(obj);
        end   
        
    end
end

