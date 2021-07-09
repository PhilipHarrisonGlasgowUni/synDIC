
%Written by Kenneth Nwanoro

function sctrBA = assemblyA(elem)

global elements

sctr = elements(elem,:);
nn   = length(sctr);

for k = 1 : nn
    sctrB(2*k-1) = 2*sctr(k)-1 ;
    sctrB(2*k)   = 2*sctr(k)   ;
end

 sctrBA = sctrB ;
end


