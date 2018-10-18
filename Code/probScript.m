syms x u s;

tSim = 600;

v = 2.5;
dT = 0.5;
r = v*dT;
al = 0.1;

A = 1/(2*(1-al)*pi);
k = 2*A^2;
C1 =  k*pi*(1-2*al);
C2 = -k*pi*al;

A = 1/(2*(1-al)*pi);
k = A^2;
C = -k*pi*(2*al-1);


if al >= 1/2
    
%     FI = funcInt([-k*x + C2, 0, k*x + C1, A],...
%         [[-pi, -al*pi, -pi + 2*al*pi, al*pi, pi];
%         [0      1          0           0    1]]);
    
    FI = funcInt([C-k*x, 0, C+k*x],...
        [[-pi, -pi*(2*al-1), pi*(2*al-1), pi];
        [0 1 0 1]]);
end

if al < 1/2
   
%     FI = funcInt([-k*x + C2, C1 + C2, k*x + C1, A],...
%         [[-pi, -pi + 2*al*pi, -al*pi, al*pi, pi];
%         [0      1          0           0    1]]);

    FI = funcInt([C-k*x, 2*C, C+k*x],...
        [[-pi, pi*(2*al-1), -pi*(2*al-1), pi];
        [0 1 0 1]]);
end


PR = ProbabilityAnalysis(al,v,dT, FI);

for i = 1:tSim/dT
    
    i*dT
    pCur = (PR.P)^s.mainCount*PR.pdInit;
    stairs(linspace(1, length(PR.pdInit),length(PR.pdInit)), pCur)    
    axis([1 length(PR.pdInit) 0  1]);
    
end

pCur
