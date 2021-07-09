function [B,J0,N] = Bmatrix(pt,elemType,e)
global nodes elements 
sctr = elements(e,:); % Reads row values of element
nn   = length(sctr);

xi=pt(1); eta=pt(2);
      N=1/4*[ (1-xi)*(1-eta);
              (1+xi)*(1-eta);
              (1+xi)*(1+eta);
              (1-xi)*(1+eta)];
      dNdxi=1/4*[-(1-eta), -(1-xi);
		         1-eta,    -(1+xi);
		         1+eta,      1+xi;
                -(1+eta),   1-xi];


J0 = nodes(sctr,:)'*dNdxi ;                % returns element Jacobian matrix

invJ0 = inv(J0);
dNdx  = dNdxi*invJ0;                      % returns derivatives of N w.r.t XY
                  % GP in global coord, used



Bfem = zeros(3,2*nn);
Bfem(1,1:2:2*nn)  = dNdx(:,1)' ;
Bfem(2,2:2:2*nn)  = dNdx(:,2)' ;
Bfem(3,1:2:2*nn)  = dNdx(:,2)' ;
Bfem(3,2:2:2*nn)  = dNdx(:,1)' ;

B = Bfem;

end
          