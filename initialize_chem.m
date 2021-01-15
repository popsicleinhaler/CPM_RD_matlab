initialize_chem_params

i_chem_0 = ((1:N_species)-1)*sz;

%~~~~~~~~setting up the chemical state of the cell~~~~~~~~~~~~~~~~~~~~~~


% D_1=0.43;                  %inactive rho/rac
% D_2=0.02;                  %active rho/rac
% D_3=0.03;                  %pax
% D_3=1;                  %pax
% D = [D_1 D_1 D_2 D_2 D_3 D_3];
%
% D=[D_1 D_2 D_1 D_2 D_3 D_3 0 0];

% D=[D_1 D_2 D_1 D_2];

% D=[D_1 D_1 D_1 D_1];

%to find total number of molecules took concentrations from paper and
% assumed sperical cell r=5um gives N=3e5*[X]
totalRho = 2250000/SF;
totalRac = 2250000/SF;
totalPax = 690000/SF;
Rho_Square = totalRho/(A);    %Average number of Rho per square
Rac_Square = totalRac/(A);    %Average number of Rac per square
Pax_Square = totalPax/(A);    %Average number of Pax per square

N_instantaneous=50;

model_params

VolCell=(0.5*10^-6)*(h*10^-6)^2; %volume of a single lattice cell in m^3
muM = 6.02214*10^23*VolCell*10^3*10^-6; %Rescales from \muM to molecules

%%%


if length(D)==9
    Rho_Square=muM*3.1;
    Rac_Square=muM*7.5;
    C_Square=muM*2.4;
end


if length(D)==9
    Rho_Square=muM*3.1;
    Rac_Square=muM*7.5;
    C_Square=muM*2.4;
end



% rough estimate of uninduced state

RhoRatio_u = 0.6;
RacRatio_u = 0.045;%0.085

PaxRatio_u = 0.082;
% PaxRatio_u = 0.002;

% rough estimate of the induced state
RhoRatio_i = 0.2;
RacRatio_i = 0.35; %0.215;

if length(D)==9
    RacRatio_u = 0.35; %0.215;
    RacRatio_i = 0.85; %0.215;
    CRatio=[0.6; 0.5];
    
    RhoRatio_i = 0.05;
    RhoRatio_u = 0.4;
end

if length(D)==9
    RacRatio_u = 0.35; %0.215;
    RacRatio_i = 0.85; %0.215;
    CRatio=[0.6; 0.5];
    
    RhoRatio_i = 0.05;
    RhoRatio_u = 0.4;
end


% RhoRatio_i = RhoRatio_u;
% RacRatio_i = RacRatio_u;



%0.215;
PaxRatio_i = 0.2;

RhoRatio=[RhoRatio_u; RhoRatio_i];
RacRatio=[RacRatio_u; RacRatio_i];
PaxRatio=[PaxRatio_u; PaxRatio_i];


K_is=1./((1+k_X*PIX+k_G*k_X*k_C*GIT*PIX*Paxtot*PaxRatio).*(1+alpha_R*RacRatio)+k_G*k_X*GIT*PIX); %intial value of some ratios
K=alpha_R*RacRatio.*K_is.*(1+k_X*PIX+k_G*k_X*k_C*Paxtot*GIT*PIX*PaxRatio);
P_i=1-PaxRatio.*(1+k_G*k_X*k_C*GIT*PIX*PAKtot*K_is.*(1+alpha_R*RacRatio));

Rho0 = Rho_Square*RhoRatio;           %active Rho
Rhoi0 = Rho_Square - Rho0;

Rac0 = Rac_Square*RacRatio;           %active Rac


if length(D)~=9
    
    %inactive Rho that's ready to convert to active Rho
    
    
    if length(D)==8
        Raci0 = Rac_Square*(1-RacRatio-gamma*K);        %inactive Rac that's ready to convert to active Rac
    else
        Raci0 = Rac_Square*(1-RacRatio);
    end
    
    Pax0 = Pax_Square*PaxRatio;           %active Rac
    if length(D)==6
        Paxi0=Pax_Square-Pax0;
    else
        Paxi0 = Pax_Square*P_i;        %inactive Rac that's ready to convert to active Rac
    end
    
    RacPak0 = (1+k_X*PIX+k_G*k_X*k_C*GIT*PIX*Paxtot*Pax0/Pax_Square).*alpha_PAK*PAKtot.*K_is .* Rac0;
    GPP0 = (k_G*k_X*k_C*GIT*PIX*K_is*PAKtot.*(1+alpha_R*Rac0/Rac_Square)) .*Pax0;
    
    RacPak0 =  Rac_Square - Rac0 - Raci0;
    GPP0 = Pax_Square - Pax0 - Paxi0;
    
    %Setting up initial state of the cell
    N0=[Raci0 Rac0 Rhoi0 Rho0 Paxi0 Pax0];
    
    N0=[Raci0 Rac0 Rhoi0 Rho0 Paxi0 Pax0 RacPak0 GPP0];
    
    
params = inline_script('model_params');
rhs_str = inline_script('eval_Rx');

str =['function Rx = rhs_fun(t,u)' newline 'u=transpose(u);' newline params newline rhs_str newline 'Rx=transpose(Rx);' newline 'end'];

fid=fopen('rhs_fun.m','w');
fwrite(fid,str,'char');
fclose(fid);

[T,Y] = ode15s(@ rhs_fun,[0 1e4],N0(1,1:N_species));
    m0=sum( N0(1,:));
%     N0(1,1:N_species)=Y(end,:);
    m0-sum( N0(1,:))
    
    N0(1,2)/Rac_Square
    N0(1,4)/Rho_Square
    N0(1,6)/Pax_Square
    
    figure(3);clf();
    plot(T,Y);
    drawnow;
else
    
    
    unscale=5e0;
    
    I_C=2.95*muM/unscale;
    I_R=0.5*muM/unscale;
    I_rho=3.3*muM/unscale;
    
    a1=1.15*muM;
    a2=1*muM;
    n=3;
    alpha=4.5/unscale;
    beta=0.3/unscale;
    d_C=1/unscale;
    d_R=1/unscale;
    d_rho=1/unscale;
    
    ff=0.4;
    
    R_b=3*muM;
    rho_b=1.25*muM;
    
    rescale=35;
    
    I_P1=10.5*muM/rescale;
    delta_P1=0.21;
    kPI5K=0.084;
    k21=0.021;
    
    kPI3K=0.00072*5;%speed these up
    kPTEN=0.432/5;
    
    P3b=.2*muM;
    
    C0=CRatio*C_Square;
    Ci0=C_Square-C0;
    
    Raci0 = Rac_Square*(1-RacRatio);
    
    P10=[1; 1]*I_P1/delta_P1;
    
    P20=P10.*(kPI5K*(1+Rac0/R_b)/2)/k21;
    P30=P20.*(kPI3K*(1+Rac0/R_b)/2)./( kPTEN*(1+Rho0/rho_b)/2);
    
    N0=[Raci0 Rac0 Ci0 C0 Rhoi0 Rho0 P10 P20 P30];
end


% N0=[Raci0 Rac0 Rhoi0 Rho0];


%setting up intial chemcial states
% x=reshape(round(N0.*cell_mask(:)),[N,N,N_species]);  %puts molecules in their places
mask=induced_mask&cell_mask;
[tmp,tmp2]=meshgrid((0:N_species-1)*sz,find(mask));
i_induced=tmp+tmp2;

x=zeros([shape ,N_species]); % where the chemical information is stored

x(i_induced)=repmat(N0(2,1:N_species),nnz(mask),1);

mask=~induced_mask&cell_mask;
[tmp,tmp2]=meshgrid((0:N_species-1)*sz,find(mask));
x(tmp+tmp2)=repmat(N0(1,1:N_species),nnz(mask),1);

% x=round(x);
x=(1+noise*rand(size(x))).*x;
x(x<0)=0;
% reaction=zeros(N,N,9);
%
% reaction(:,:,3) = delta_rho;                                             %From active rho to inactive rho
% reaction(:,:,4) = delta_R;                                               %From active Rac to inactive Rac
% reaction(:,:,6) = delta_P;                                               %From phosphorylated Pax to unphosphorylated Pax


alpha_chem=zeros([shape N_rx]);
alpha_rx=zeros(1,N_rx);
alpha_diff=zeros(6,1); %the 6 here is not the same as N_rx...need to figure out a system
ir0=((1:N_rx)-1)*sz;

RacRatio0=zeros(shape);
RhoRatio=zeros(shape);
RacRatio=zeros(shape);
RbarRatio=zeros(shape);
PaxRatio=zeros(shape);
K=zeros(shape);
K_is=zeros(shape);
I_Ks=zeros(shape);

feedback=zeros(shape);
Q_R=zeros(shape);
Q_C=zeros(shape);
Q_rho=zeros(shape);
Q_P=zeros(shape);
vox=cell_inds(1:A);

eval_model

% [x,sz,alpha_rx,...
%     alpha_chem,PaxRatio,RhoRatio,K_is,K,...
%     RacRatio,RbarRatio,I_Ks,reaction,ir0,...
%     k_X,PIX,k_G,k_C,GIT,Paxtot,alpha_R,I_K,I_rho,I_R,L_R,m,L_rho,B_1,L_K,...
%     PAKtot,i]=update_alpha_chem(x,sz,alpha_rx,...
%     alpha_chem,PaxRatio,RhoRatio,K_is,K,...
%     RacRatio,RbarRatio,I_Ks,reaction,ir0,...
%     k_X,PIX,k_G,k_C,GIT,Paxtot,alpha_R,I_K,I_rho,I_R,L_R,m,L_rho,B_1,L_K,...
%     PAKtot,i);

% update_all=true;
% update_alpha_chem

% RhoRatio0=RhoRatio;
% RacRatio0=RacRatio;
