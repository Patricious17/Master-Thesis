%% THE MASTER
%%%%%%%%%%%%%%

close all; clear all;
mastercount = 1;
initM; % initializes values and objects
preplot; % ploting before simulation



while(mastercount <= 4)
    
    while s.mainCount < s.simT/s.dT
        s.DEventTrigger(a,PR);  % dEventsTrigger;
        a.Sense(s);  % agents sensing enviromental physical quantities
        a.CogProc(s); % agents undergoing cognitive processing
        PR.update(a,s);
        plotAgents;
        s.ContinuousStep(a); % continuousStep;
        s.mainCount = s.mainCount + 1;
        write2comm; % writes observed data to command window
        % s.mainCount == 10/s.dT
    end
    mastercount = mastercount + 1; 
    clear a;
    initM;
    close all
end

postplot; % ploting after simulation

pause(60);

close all; clear all;