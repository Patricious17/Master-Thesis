au2cm = 20; % converting unit of arena to cm

numA = 100
rArena = au2cm/2;

dT = 0.05;
simT = 6000;

heatPos = [au2cm/2, au2cm/2];
heatTemp = [36];
sigma = 0.1;

alpha = 0.1

a = Agents(numA, alpha);
s = Simulation(numA, dT, simT, heatPos, heatTemp, sigma, au2cm, 1);
ut = util();

v = a.aParams.stdVel;
dT = s.dT;
r = v*dT;
al = a.aParams.alpha(1);

PR = ProbabilityAnalysis(a,s,al,v,dT,rArena);

s.constructCountProbs(PR);

plotIt = 0;
startplot = 10;