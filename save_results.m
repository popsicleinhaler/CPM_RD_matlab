iter=iter+1;

center(:,iter)=com(cell_mask);
Results(:,:,1,iter)=cell_mask;
Results(:,:,2:(N_species+1),iter)=x; %storing the results
Times(iter)=time;

areas(iter)=A;
perims(iter)=Per;

Ham0(iter)=H0;
Hchem(iter)=dH_chem;
