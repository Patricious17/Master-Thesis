List = ls;
inputFormat = 'fig';
outputFormat = 'png';

for ii = 3:size(List,1)
    
    if strfind(List(ii,:),['.',inputFormat]) > 0 
        disp(['Converting ',List(ii,:)])
        h=openfig(List(ii,:),'new','invisible');
        outputName = List(ii,1:end-length(inputFormat)-1);
        saveas(h,outputName,outputFormat)
        close(h);
    end
    
end

disp('Conversion complete')