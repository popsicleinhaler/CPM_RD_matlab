
plotting=usejava('desktop') && isempty(getCurrentTask());
mk_rxn_files('chem_Rx_Pax_Kathy');
% plotting=false;
if plotting %do not display pictures when running in parallel...i.e., on the cluster
    
%     figure(1);clf();
%     set(gcf,'defaultaxesfontsize',14);
%     d=[0.04, 0.04];
%     panelA=subplot(2,2,1); annotatePlot('A',22,d);
%     panelB=subplot(2,2,2); annotatePlot('B',22,d);
%     panelC=subplot(2,2,3); annotatePlot('C',22,d);
%     panelD=subplot(2,2,4); annotatePlot('D',22,d);

initialize_pic
    
end



%open(vid);


nrx=3e4; %number of times reactions are carried out in a chem_func loop

noise=0.0005;
dt=0.1;
Ttot=16*3.6e3; %Total simulation time

SF=2; % speed factor I divide molecule number by this for speed
Gsize=80; %length of the grid in um
N=150; % number of points used to discretize the grid
shape=[N,N];
sz=prod(shape);
h=Gsize/(N-1); %length of a latice square
cpm_wait=5;

vmax=3/60; %max speed of the cell
picstep=5;
cpmsteps=5;

cpmstep0=h/vmax;
cpmstep=cpmstep0/cpmsteps;



[j, i] = meshgrid(1:shape(2),1:shape(1)); %the i and j need to be reversed for some reason (\_(:0)_/)

div=0.1;

%prepare some .m files to model the chemical reactions from the reactions specified in `chem_Rx` file


restart=false;
tic

if ~restart
    initialize_cell_geometry
    initialize_chem_params
    initialize_chem %all reaction parameters are getting initialized
    initialize_cellular_potts
end

lastplot=0;
lastcpm=0;

%timepoints where we take a frame for the video

initialize_results


% Results=zeros(N,N,N_species+1,floor(Ttot/picstep)+1); %an array where we store results
pic %takes a frame for the video
if plotting && usejava('desktop') && isempty(getCurrentTask())
    delete test.gif
    gif('test.gif','frame',panel1)
end
reactions=0; %intializing a reaction counter


%diffusion timestep
eps=0.00005;
pmax=50;%0.5;%max allowed pT for one cell

% dt=pmax*(h^2)/(max(D)*size(jump,2));%auto-determine timestep


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

% 
% if (1/a_total)*nrx>h/(4*vmax) %makes sure that you don't stay in the CPM__chem func loop for to long
%     error('cell moving to fast consider lowering nrx')
% end

numDiff=0;
numReac=0;
cpmcounter=0;
%arrays recording Ratio change
%after run, plot TRac/TRho over Timeseries
Timeseries=[];
TRac=[];
TRho=[];
TPax=[];

last_time=time; %used to time the CMP_step
% tic
rx_speedup=2;
rx_count=zeros(shape);
dt_diff=zeros(size(D));
P_diff=0.5;

% scr='FVM_CPM';
% FVM_fn=mk_fun2(scr,{'gamma','jump','time'});

d0=sum(x(:));
% FVM_call=[getFunctionHeader(FVM_fn) ';'];

% disp(FVM_call)

if isempty(getCurrentTask()); copyNum=[]; end

% eval(['try' newline...
%     FVM_call newline...
%     'catch err' newline...
%     'disp(getReport(err));' newline...
%     'end']);

% run(scr)

FVM_CPM_loop

toc

if isempty(getCurrentTask())  
%     close(vid);
    fn=['results/final_B_' num2str(B) '.mat'];
    ls results
    disp(['saving to: ' fn]);
    save(fn, '-v7.3');
else
    fn=['results/final_B_' num2str(B) '_copy' int2str(copyNum) '.mat'];
    disp(['saving to: ' fn]);
    ls results
    save(fn, '-v7.3');

end
