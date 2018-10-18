function [ rArr ] = LPF( Arr )

forward  = [Arr(2:end);0];
backward = [0; Arr(1:end-1)];

fKoef = (1/4) * ones(length(forward ), 1); fKoef(1  ,1) = 1/2;
bKoef = (1/4) * ones(length(backward), 1); bKoef(end,1) = 1/2;
mKoef = (1/2) * ones(length(Arr     ), 1);

rArr = bKoef.*backward + fKoef.*forward + mKoef.*Arr;

end

