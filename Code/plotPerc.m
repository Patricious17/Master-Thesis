pCurSum = cumsum(PR.pcur);

flagCurSum = find(pCurSum >= 0.6);

elpCurSum = flagCurSum(1);
%%

pSimCurSum = cumsum(s.countProbs);

flagSimCurSum = find(pSimCurSum >= 0.6);

elpSimCurSum = flagSimCurSum(1);


