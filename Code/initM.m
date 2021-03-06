au2cm = 20; % converting unit of arena to cm

numA = 200;
rArena = au2cm/2;

dT = 0.05;
simT = 600;

heatPos = [au2cm/2, au2cm/2];
heatTemp = [36];
sigma = 0.13;

s = Simulation(numA, dT, simT, heatPos, heatTemp, sigma, au2cm, 1);
a = Agents(numA, mastercount);
ut = util();

v = a.aParams.stdVel;
dT = s.dT;
r  = v*dT;
al = a.aParams.alpha(1);

PR = ProbabilityAnalysis(a,s,al,v,dT,rArena);

s.constructCountProbs(PR);

plotIt = 0;
startplot = 1;
iter = 10;