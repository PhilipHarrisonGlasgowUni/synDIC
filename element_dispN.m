function U = element_dispN(e,u)

% returns nodal displacements 

global elements

sctr = elements(e,:);
nn   = length(sctr);

idx = 0 ;
stdU   = zeros(2*nn,1);
for in = 1 : nn
    idx = idx + 1;
    nodeI = sctr(in) ;
    stdU(2*idx-1) = u(2*nodeI-1);
    stdU(2*idx)   = u(2*nodeI  );
end



% total
U = [stdU];
end