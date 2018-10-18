%% plots

figure(1);




if(s.mainCount >= (startplot + plotIt)/s.dT)
%if (mod(s.mainCount, 1) == 0)   
    
    if (s.mode == 1)
        
        if (s.mainCount ~= startplot/s.dT)
          delete(a2plota, a2plotb, a2plotc,... 
                 a2plotd, a2plote, a2plotf,...
                 a2plotk, heat2plot);
        end
    
        a2plota = logical(s.sqA.reg == 'a');
        a2plota = plot(s.pos.X(a2plota), s.pos.Y(a2plota), 'ro');
        hold on; grid on;
        
        a2plotb = logical(s.sqA.reg == 'b');
        a2plotb = plot(s.pos.X(a2plotb), s.pos.Y(a2plotb), 'go');
        
        a2plotc = logical(s.sqA.reg == 'c');
        a2plotc = plot(s.pos.X(a2plotc), s.pos.Y(a2plotc), 'bo');
        
        a2plotd = logical(s.sqA.reg == 'd');
        a2plotd = plot(s.pos.X(a2plotd), s.pos.Y(a2plotd), 'yo');
        
        a2plote = logical(s.sqA.reg == 'e');
        a2plote = plot(s.pos.X(a2plote), s.pos.Y(a2plote), 'mo');
        
        a2plotf = logical(s.sqA.reg == 'f');
        a2plotf = plot(s.pos.X(a2plotf), s.pos.Y(a2plotf), 'co');
        
        a2plotk = logical(s.dS.wait == 1);
        a2plotk = plot(s.pos.X(a2plotk), s.pos.Y(a2plotk), 'ko');        
    
    else
        
        if (s.mainCount ~= 1)
          delete(a2plot, a2plotk, heat2plot);
        end    
        
        a2plot = plot(s.pos.X, s.pos.Y, 'ro');
        hold on; grid on;        
        a2plotk = logical(s.dS.wait == 1);
        a2plotk = plot(s.pos.X(a2plotk), s.pos.Y(a2plotk), 'ko');
    end
    
    heat2plot = plot(s.heat.PosX,s.heat.PosY, 'r*');
    
    axis([0 s.sqA.dimX 0 s.sqA.dimY])
    
    if (mod(s.mainCount,5) == 0)
        
        if (s.mainCount >startplot/s.dT)
            delete(plotProb, plotSimProb); %plotPercpCur, plotPercpSimCur);
        end
        
               
        xArr = linspace(PR.params.d/s.au2cm, PR.params.d*length(PR.pcur)/s.au2cm, length(PR.pcur));
        pSimCur = 0.5*(filter(1/10*ones(10,1),1,s.countProbs) + filter(1/10*ones(10,1),1,fliplr(s.countProbs)));
        plotPerc;
        
        figure(4)        
        xlabel('Distance from center');
        ylabel('Probability'); 
        
        %plotPercpCur = line(elpCurSum*PR.params.d/s.au2cm.*[1 1],get(axes,'XLim'),'Color',[1 0 0]);
        
        %./((PR.pdInit.*((PR.nCell*PR.d)^2*pi)).^(-1));
                
        
        plotProb    = stairs(xArr, PR.pcur);        
        hold on;       
        plotSimProb = stairs(xArr, pSimCur, 'r');%ut.LPF(s.countProbs))
        %stairs(linspace(1, length(PR.pdInit),length(PR.pdInit)), pCur./PR.pdInit./(PR.params.rArena^2*pi),'r')      
        %plotPercpCur    = plot([elpCurSum*PR.params.d/s.au2cm, elpCurSum*PR.params.d/s.au2cm],[0, 1],'b');
        %plotPercpSimCur = plot([elpSimCurSum*PR.params.d/s.au2cm, elpSimCurSum*PR.params.d/s.au2cm],[0, 1],'r');
                
        axis([PR.params.d/s.au2cm PR.params.d*length(PR.pcur)/s.au2cm 0  1.1*max([PR.pcur; s.countProbs])]);
        legend('Distribution from analysis', 'Distribution from simulation');
        
        
    end
    
    if(s.mainCount > (startplot + plotIt)/s.dT)
        plotIt = plotIt + 5;
        figure(4)
        filename = sprintf('AAal%dAAT%dAAdT%dAAang%dAApr.fig',...
                           a.aParams.alpha(1,1),...
                           s.mainCount*s.dT    ,...
                           s.dT                ,...
                           a.aParams.angleRange);
        %savefig(filename)
        
        figure(1)
        filename = sprintf('AAal%dAAT%dAAdT%dAAang%dAAare.fig',...
                           a.aParams.alpha(1,1),...
                           s.mainCount*s.dT    ,...
                           s.dT                ,...
                           a.aParams.angleRange);
        %savefig(filename)
    
    end
    %pause(0.01);    
end
