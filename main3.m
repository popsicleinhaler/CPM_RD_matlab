% clc
% clearvars
% close all;
% set(0,'DefaultFIgureVisible','on');
%restarting the environment

% mkdir 'results'
%vid = VideoWriter(['results'],'MPEG-4'); % this saves videos to mp4 change to whatever's convenient

figure(1);clf();
set(gcf,'defaultaxesfontsize',14);
d=[0.04, 0.04];
panelA=subplot(2,2,1); annotatePlot('A',22,d);
panelB=subplot(2,2,2); annotatePlot('B',22,d);
panelC=subplot(2,2,3); annotatePlot('C',22,d);
panelD=subplot(2,2,4); annotatePlot('D',22,d);

Results=[];
Times=[];

%open(vid);


nrx=1e5; %number of times reactions are carried out in a chem_func loop


Ttot=3.2e3; %time the simulation end
SF=2; % speed factor I divide molecule number by this for speed
Gsize=100; %length of the grid in um
N=30; % number of points used to discretize the grid
shape=[N,N];
sz=prod(shape);
h=Gsize/(N-1); %length of a latice square
vmax=3/60; %max speed of the cell
picstep=5;
cpmsteps=5;
cpmstep=h/(vmax*cpmsteps);


[j, i] = meshgrid(1:shape(2),1:shape(1)); %the i and j need to be reversed for some reason (\_(:0)_/)

div=0.1;

%prepare some .m files to model the chemical reactions from the reactions specified in `chem_Rx` file
mk_rxn_files('chem_Rx')

initialize_cell_geometry
initialize_cellular_potts
initialize_chem %all reaction-diffusion parameter are getting initialized


lastplot=0;
lastcpm=0;
tic
 %timepoints where we take a frame for the video
z=1;

center=zeros(floor(Ttot/picstep)+1,2); %an array where we store the COM
center(z,:)=com(cell_mask);

% Results=zeros(N,N,N_species+1,floor(Ttot/picstep)+1); %an array where we store results
pic %takes a frame for the video
gif('test.gif','frame',panelC)

reactions=0; %intializing a reaction counter


%diffusion timestep
eps=0.00005;
pmax=0.004;%0.5;%max allowed pT for one cell

dt=pmax*(h^2)/(max(D)*size(jump,1));%auto-determine timestep

%intializing variables for enumerate_diffusion.m making sure their size is
%constant
N_dim=size(jump,2);
ij0=(1:(sz))';
diffuse_mask=false(N_dim,sz);
num_diffuse=zeros(1,size(jump,2));
ij_diffuse=zeros(4,(N)*(N));
diffusing_species_sum=zeros(N_dim,length(D));
num_vox_diff=zeros(1,sz);
pT0 = zeros(sz,length(D));
pi = zeros(N_dim,sz);
dt_diff=zeros(size(D));

enumerate_diffusion %determines the possible diffusion reactions in a way that be convereted to c

%vectorized indcies for the reaction and diffusion propensites
id0=(diffusing_species-1)*sz;


%initializing total chemical reaction and diffusion-reaction propensities
alpha_diff=sum(diffusing_species_sum).*D/(h*h);
alpha_rx=sum(alpha_chem(ir0 + cell_inds(1:A)));
alpha_rx2=alpha_rx;
a_total=sum(alpha_diff)+sum(alpha_rx(:));


if (1/a_total)*nrx>h/(4*vmax) %makes sure that you don't stay in the CPM__chem func loop for to long
    error('cell moving to fast consider lowering nrx')
end

numDiff=0;
numReac=0;
%arrays recording Ratio change
%after run, plot TRac/TRho over Timeseries
Timeseries=[];
TRac=[];
TRho=[];
TPax=[];

last_time=time; %used to time the CMP_step
tic
rx_speedup=2;
rx_count=zeros(shape);
dt_diff=zeros(size(D));
P_diff=0.5;

SSA='SSA02';
SSA_fn=mk_fun(SSA);
SSA_call=[getFunctionHeader(SSA_fn) ';'];

while time<Ttot
    A=nnz(cell_mask); %current area
    cell_inds(1:A)=find(cell_mask); %all cell sites padded with 0s
    
    while (time-last_time)<Ttot
        
        alpha_rx=sum(alpha_chem(ir0 + cell_inds(1:A)));
        
        %run the SSA
        eval(SSA_call); 

        reactions=reactions+nrx; %reaction counter
        

        
        if time>=lastcpm+cpmstep
            
            for kk=1:Per/cpmsteps %itterates CPM step Per times
                CPM_step
            end
            
            enumerate_diffusion %recaucluates diffusable sites
            lastcpm=time;
        end
        
                if time>=lastplot+picstep || time==lastcpm % takes video frames
            

            
            pic
            gif
%             Timeseries=[Timeseries time];
%             
%             TRac=[TRac sum(sum(x(:,:,4)))/sum(sum(sum(x(:,:,[4 2 7]))))];
%             TRho=[TRho sum(sum(x(:,:,3)))/sum(sum(sum(x(:,:,[1 3]))))];
%             TPax=[TPax sum(sum(x(:,:,6)))/sum(sum(sum(x(:,:,[6 5 8]))))];
% 
%             z=z+1;
%             center(z,:)=com(cell_mask);
            lastplot=time;
            time;
%             reactions
%             toc;
        end
        
    end
    
    last_time=time;
    

    
    enumerate_diffusion %recaucluates diffusable sites
end



%calculates speed by the distance the COM moved every 120s 
%thats (how they do it experimentally)
% dx=zeros(floor(finaltime/120),1);
% dx(1)=sqrt(sum((center(120/picstep,:)-center(1,:)).^2));
% for i=2:length(dx-1)
%     dx(i)=sqrt(sum((center(i*120/picstep,:)-center((i-1)*120/picstep,:)).^2));
% end
% v=dx/120*3600;
% 
% %saving final results 
toc


% figure(1);
% plot(Timeseries,TRho,Timeseries,TRac,Timeseries,TPax);
% legend('Rho','Rac','Pax','Location','Best');
% xlabel('Time');
% title(['B = ' num2str(B_1)]);


%close(vid);
% cur=pwd;
% cd results
% save(['final'])
% cd(cur)
