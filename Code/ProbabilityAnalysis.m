classdef ProbabilityAnalysis < handle
    
    properties
        
        params;        
                
        p;            
        P;
        PreMat;
        pdInit;     
        pNWait;
        pwaitE;
        diskFlMat;
        pcur;
        
    end
    
    methods
        function obj = ProbabilityAnalysis(a,s,al, v, dT,rArena)
                                    
            d = 2*v*dT*cos(1.1655);
            
            obj.params = struct( 'rArena', rArena ,...
                                 'r'     , v*dT   ,...
                                 'd'     , d      ,...
                                 'theta' , 1.1655 ,...
                                 'al'    , al     ,...
                                 'nCell' ,floor(rArena/d));
                             
            obj.generateInitialDist();
            
            obj.p = zeros(obj.params.nCell,3);
            obj.pwaitE = [];
            obj.P = zeros(obj.params.nCell,obj.params.nCell);
                        
            for i = 1 : obj.params.nCell
                obj.generateProb(i,a);
            end
            
            obj.generateDiskFlagMat(a,s);
            obj.generatepWaitE(a,s);
            obj.generatePreMatrix();
            obj.update(a,s);
        end
        
        function generatePreMatrix(obj)
            cMat = zeros(obj.params.nCell,obj.params.nCell);
            
            for i = 1: obj.params.nCell-1
                cMat(i, i+1) = obj.p(i,1);
            end
                
            for i = 2: obj.params.nCell
                cMat(i, i-1) = obj.p(i,3);
            end         
            obj.PreMat = cMat;
        end
        
        function generateProb(obj, i,a)            
            sigma = sqrt((a.aParams.angleRange(1))^2*(1-obj.params.al)^2/(obj.params.al*(2-obj.params.al)));
            obj.p(i,1) = obj.integrateNormT(sigma);
            obj.p(i,3) = obj.integrateNormB(sigma);
            obj.p(i,2) = 1-obj.p(i,1)-obj.p(i,3);            
        end
        
        function update(obj,a,s)
            
            N = a.numA;
            
            obj.pNWait = 1 - (1 - (1-obj.diskFlMat*obj.pcur).^(N-1)).*obj.pwaitE;
            
            obj.P = obj.PreMat.*repmat(obj.pNWait', obj.params.nCell,1);            
            obj.P = obj.P + diag(ones(obj.params.nCell,1) - [diag(obj.P, -1); 0] - [0; diag(obj.P, 1)]);
                        
            obj.pcur = obj.P*obj.pcur;
        end
        
        function generateDiskFlagMat(obj,a,s)
             
             half = floor(a.aParams.pZoneR(1)/obj.params.d);
             numDisks = 1 + 2*half;
             flagVector = zeros(1,obj.params.nCell);
             flagVector(1,1:numDisks) = 1;
             
             mat1 = zeros(half + 1, obj.params.nCell);
             mat2 = mat1;
             mat3 = [];
             
             start = obj.params.d/2 + half*obj.params.d;
             last = obj.params.nCell * obj.params.d - start;
             dist = linspace(start, last, obj.params.nCell - 2*half);
             coef = atan2(a.aParams.pZoneR(1)*ones(1,length(dist)), dist);
             %coef(1:24)=coef(10);
             
             for i = 1:half+1                 
                mat1(i,:)=flagVector%*coef(1);
             end             
             
             for i = 1:half+1
                mat2(i,:)=circshift(flagVector, [0 -numDisks])%*coef(end);
             end
             
             for i = 1 : obj.params.nCell - 2*(half+1)
                mat3 = [mat3; circshift(flagVector,[0 i])]%*coef(i+1)];
             end
             
             obj.diskFlMat = [mat1;mat3;mat2];          
        end
        
        function generatepWaitE(obj, a, s)
            
            gaussT = (s.heat.temp(1) - s.surrTemp) *...
                      gaussmf(linspace(obj.params.d/2/s.au2cm, obj.params.d/2/s.au2cm + (obj.params.nCell-1)*obj.params.d/s.au2cm, obj.params.nCell), [s.heat.sigma, 0]);                  
                                          
            diskTemp = s.surrTemp + gaussT;            
            diskWait = a.Fwait(a.cogParams.maxWait, a.cogParams.expA, diskTemp);
                        
            obj.pwaitE = []; 
            for j = 1:obj.params.nCell                
                %obj.pwaitE = [obj.pwaitE; (1-s.dT*(diskWait(j))^(-1))]; 
                obj.pwaitE = [obj.pwaitE; exp(-1/diskWait(j)*s.dT)]; 
            end
            %filter = logical(diskWait<s.dT);
            %obj.pwaitE(filter) = 0;
        end
        
        function generateInitialDist(obj)
            obj.pcur=[];
            
            for i = 1 : obj.params.nCell
                obj.pcur = [obj.pcur; ((i*obj.params.d)^2 - ((i-1)*obj.params.d)^2)*pi/((obj.params.nCell*obj.params.d)^2*pi)];
            end
        end
                
        function pret = integrateNormT(obj, sigma)
            
            mu = 0;
            
            pcur = 2 * (normcdf(obj.params.theta,mu,sigma) - normcdf(0,mu,sigma));
            pret = pcur;
            
            j = 0;
            while (pcur > 0.005)
                j=j+1;
                
                pcur = 2 * (normcdf(2*pi*j + obj.params.theta,mu,sigma) - normcdf(2*pi*j - obj.params.theta,mu,sigma));
                pret = pret + pcur;                
            end
        end
        
        function pret = integrateNormB(obj, sigma)
            
            mu = 0;
            
            pcur = 2 * (normcdf(pi + obj.params.theta,mu,sigma) - normcdf(pi - obj.params.theta,mu,sigma));
            pret = pcur;
            
            j = 0;
            while (pcur > 0.005)
                j=j+1;
                
                pcur = 2 * (normcdf(pi + 2*pi*j + obj.params.theta, mu, sigma) - normcdf(pi + 2*pi*j - obj.params.theta,mu,sigma));
                pret = pret + pcur;                
            end            
        end
    end
end

