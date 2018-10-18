% S = 15^2*pi;
% N = 20;
% pWait = [];
% 
% for i = 1:N
%     pZone = 2.5;
%     pWait = [pWait; nchoosek(N-1,i-1) * ...
%         (   (pZone /S)^i) * ...
%         (((S-pZone)/S)^(N-1-i))...
%         ];
% end
% theta = 1.1655;
% mu = 0;
% al=0.2;
% sigma = sqrt((pi/2)^2*(1-al)^2/(al*(2-al)));
% 
% pcur = 2 * (normcdf(theta,mu,sigma) - normcdf(0,mu,sigma));
% pret = pcur
% 
% j = 0;
% while (pcur > 0.000000001)
%     j=j+1;
%     
%     pcur = 2 * (normcdf(2*pi*j+theta,mu,sigma) - normcdf(2*pi*j-theta,mu,sigma))
%     pret = pret + pcur
% end
% 
% pret1 = pret
% 
% pcur = 2 * (normcdf(theta + pi,mu,sigma) - normcdf(-theta + pi,mu,sigma));
% pret = pcur
% 
% j = 0;
% 
% while (pcur > 0.000000001)
%     j=j+1;
%     
%     pcur = 2 * (normcdf(pi + 2*pi*j + theta,mu,sigma) - normcdf(pi + 2*pi*j - theta,mu,sigma))
%     pret = pret + pcur
% end
% 
% pret2 = pret
% 
% % n = 5;
% % sigma = sqrt((pi/2)^2*(1-al)^2*(1-(1-al)^(2*n))/(2*al-al^2));
% 
% 
% 
% pcur = 2 * (normcdf(pi-theta,mu,sigma) - normcdf(theta,mu,sigma))+...
%        2 * (normcdf(2*pi-theta,mu,sigma) - normcdf(pi + theta,mu,sigma));
% 
% pret = pcur
% 
% j = 0;
% 
% 
% while (pcur > 0.000000001)
%     j=j+1;
%     
%     pcur = 2 * (normcdf(pi - theta + 2*pi*j,mu,sigma) - normcdf(2*pi*j+theta,mu,sigma))+...
%            2 * (normcdf(2*pi - theta + 2*pi*j,mu,sigma) - normcdf(2*pi*j+pi+theta,mu,sigma));
%     pret = pret + pcur
% end
% 
% pret3 = pret

Arr = [1 2 3 4 5 6 7 8 9 9 10 11 11 12]';



forward  = [Arr(2:end);0];
backward = [0; Arr(1:end-1)];

fKoef = (1/4) * ones(length(forward ), 1); fKoef(1  ,1) = 1/2;
bKoef = (1/4) * ones(length(backward), 1); bKoef(end,1) = 1/2;
mKoef = (1/2) * ones(length(Arr     ), 1);
rArr = bKoef.*backward + fKoef.*forward + mKoef.*Arr;



