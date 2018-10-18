numDisks = 7;
nCell = 20
flagVector = zeros(1,nCell);
flagVector(1,1:numDisks) = 1;
mat2 = []; mat3 = [];

mat1 = zeros((numDisks-1)/2+1, nCell);
mat2 = mat1;
for i = 1:(numDisks-1)/2+1
    mat1(i,:)=flagVector;
end

for i = 1:(numDisks-1)/2+1
    mat2(i,:)=circshift(flagVector, [0 -numDisks]);
end

for i = 1 : (nCell - numDisks - 1)
    mat3 = [mat3; circshift(flagVector,[0 i])];
end
MAT = [mat1;mat3;mat2];