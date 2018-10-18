% script used for function ploting and cout-ing values  
% used in model, prior to simulation

figure(2)

plot(linspace(0,2,20), s.surrTemp + (s.heat.temp(1) - s.surrTemp) * gaussmf(linspace(0,2,20),[s.heat.sigma, 0]));

title('stationary state temperature distribution aroung source of heat');
xlabel('distance from heat source / square of arena units');
ylabel('temperature/°C');

figure(3)

plot(linspace(0,36,40), ... 
      a.cogParams.maxWait * ...
     (exp(a.cogParams.expA * linspace(0,36,40)) - 1) / ...
     (exp(a.cogParams.expA*36) - 1));
 hold on
 
 plot(linspace(0,36,40), ... 
      a.cogParams.maxWait * ...
     (exp(a.cogParams.expA * linspace(0,36,40))) / ...
     (exp(a.cogParams.expA*36)));
 
title('mapping temperature to waiting time');
xlabel('temperature/°C');
ylabel('waiting time in seconds');
