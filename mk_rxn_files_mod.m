function  mk_rxn_files(f)

predef_spatial = {'bndry_mask'}; %pre-defined spatial variables that will be provided at runtime



[chems,S_,rate_constants,fast_chems,fast_pair,fast_affinity, S_cat, species_fast,stoic_fast, S_fast, S_cat_fast] = getChemRxns(f);
vars=getInitialized(f,true);
chems=regexprep(chems,':','');
chems=regexprep(chems,'-','_');

str=fileread(f);

str=regexprep(str,"%[^\n]*(\n)?",'$1'); %remove block comments
str=regexprep(str,"\.\.\.\n",""); %remove elipses
str=regexprep(str,"\'[^\'\n\r]+\'",''); %remove hardcoded strings with single quotes
str=regexprep(str,'\"[^\"\n\r]+\"',''); %remove hardcoded strings with double quotes
str=regexprep(str,'function[^\=]+\=[^\=]+\)',''); %remove function definition




code=' \t\f\*\+\-\/\,\=\(\)\[\]\>\<\&\~\;\:\|\{\}\^\.';
numer=['0-9' code(2:end)];
name=['([a-zA-Z][a-zA-Z_0-9]*)'];





%figure out which quantities are spatially variable
ass=cellfun(@(x) ['(?<![a-zA-Z_0-9])' x '(?:[ \t\f]*)?=([^\n\r\;]+)'],vars,'UniformOutput',0);


par_defs = regexp(str,'(?:\n|^)(?:p|par|param)[ \t\f]([^\n]+)','tokens');
str = regexprep(str,'(?:\n|^)(?:p|par|param)[ \t\f]([^\n]+)','');

model_defs = regexp(str,ass,'match');
model_defs = [model_defs{:}];
if ~isempty(model_defs)
    model_split = regexp(model_defs,[name '[ \t\f]*=([^=]+)'],'tokens');
    model_split=[model_split{:}];
    model_pars = cellfun(@(x) x{2}, model_split, 'UniformOutput', false);
    model_pars = regexp(model_pars,name,'tokens');
    model_pars = [model_pars{:}];
    model_pars = [model_pars{:}];
else
    model_defs = {};
    model_split = {};
    model_pars = {};
end



rate_con_vars = regexp(rate_constants,name,'tokens');
rate_con_vars = [rate_con_vars{:}];
rate_con_vars = [rate_con_vars{:}];

fast_params = regexp(fast_affinity,name,'tokens');
fast_params = [fast_params{:}];
if ~isempty(fast_params)
    fast_params = [fast_params{:}];
end


model_vars = cellfun(@(x) x{1}, model_split, 'UniformOutput', false);
model_var_defs = cellfun(@(x) x{2}, model_split, 'UniformOutput', false);

model_pars = unique([model_pars fast_params rate_constants],'stable');
model_pars = setdiff(model_pars, [model_vars chems]);
model_par_vals = num2cell(repmat('0',length(model_pars),1));









if ~isempty(par_defs)
    par_defs=[par_defs{:}];
    
    par_default = regexp(par_defs,'\*(?:[ \t\f]*)?=([^\,\;]+)', 'tokens' );
    par_default = par_default{1};
    
    if ~isempty(par_default)
        model_par_vals = cellstr(repmat(string(par_default{1}{1}),length(model_pars),1));
    end
    
    pars= regexp(par_defs,[name '(?:[ \t\f]*)?='], 'tokens' );
    pars=[pars{:}];
    pars=[pars{:}];
    
    par_vals =      regexp(par_defs,[name(2:end-1) '(?:[ \t\f]*)?=([^\,\;\n\r]+)'], 'tokens' );
    par_vals = [par_vals{:}];
    par_vals = [par_vals{:}];
    
    if ~isempty(pars)
        i_par = cellfun(@(p) find(strcmp(p,model_pars),1),pars,'UniformOutput',0);
        matched = cellfun(@(x) ~isempty(x) ,i_par);
        model_par_vals([i_par{:}]) = par_vals(matched);
    end
    vars=setdiff(vars,pars,'stable');
    
    
end

par_refs = strcat(['(?<=(?:^|[' code ']))('],model_pars,[')(?=(?:$|[' code ']))'])';
par_reps = string(model_par_vals);


spatial=false(size(vars));
tmp=~spatial;

rhs=regexp(str,ass,'tokens');
rhs=[rhs{:}];
if ~isempty(rhs)
    rhs=cellfun(@(x) x{1},rhs,'UniformOutput',false);
end
spatial_vars=[chems predef_spatial];
ref=@(x) ['(:?[' code '\n]|^)(?<var>' x ')(:?[' code '\n]|$)'];

spatial_ref=cellfun(@(x) ref(x),spatial_vars,'UniformOutput',0);
if ~isempty(rhs)
    tmp=cell2mat(cellfun(@(x) any(cellfun(@(y) ~isempty(y),regexp(x,spatial_ref,'tokens'))),rhs,'UniformOutput',0));
    
    while any(tmp~=spatial)
        
        spatial_vars=unique([spatial_vars vars(tmp)],'stable');
        spatial(tmp&~spatial)=1;
        
        spatial_ref=cellfun(@(x) ref(x),spatial_vars,'UniformOutput',0);
        tmp=cell2mat(cellfun(@(x) any(cellfun(@(y) ~isempty(y),regexp(x,spatial_ref,'tokens'))),rhs,'UniformOutput',0));
        
    end
    
end

spatial_vars=spatial_vars(length(chems)+1:end);
ref=@(x) ['(?<pre>[' code '\n]|^)(?<var>' x ')(?<post>[' code '\n]|$)'];
spatial_ref=cellfun(@(x) ref(x),spatial_vars,'UniformOutput',0);



sym_str= ['syms ' strjoin(unique([model_pars model_vars chems],'stable'),' ') ];


pair_inds = arrayfun(@(i) strcmp(chems,fast_pair{i})',1:length(fast_pair),'UniformOutput',false);
fast_inds = arrayfun(@(i) strcmp(chems,fast_chems{i})',1:length(fast_chems),'UniformOutput',false);


S_tot = [S_ S_fast];

lcon = null(S_tot','r');
lcon=rref(lcon')';

N_con=size(lcon,2);

rate_str = @(r) regexprep(strjoin(strcat(chems(r>0),cellstr(repmat('.^',[nnz(r(r>0)),1]))',cellstr(string(r(r>0)))'),'.*'),'\.\^1(?=($|\.))','');
rates_fast=cell(length(fast_affinity),1);
for i=1:length(fast_affinity)
    r=S_fast(:,2*i-1:2*i);
    rates_fast{i} = strcat(rate_str(r(:,1)'),'*',fast_affinity{i},'-',rate_str(r(:,2)));
end


%% user-specified model definitions

lines=[model_defs ...
    arrayfun(@(i) ['alpha_chem(vox+' num2str(i-1) '*sz)=(' rate_constants{i} ')' strjoin(arrayfun(@(j) chemRateString(chems{j},-S_(j,i)),1:size(S_,1),'UniformOutput',0),'')],1:length(rate_constants),'UniformOutput',0)];

lines = regexprep(lines,spatial_ref,'$<pre>$<var>\(vox\)$<post>');
% fast_affinity_0=fast_affinity;
% fast_affinity = regexprep(fast_affinity,spatial_ref,'$<pre>$<var>\(vox\)$<post>');

chem_ref=cellfun(@(x) ref(x),chems,'UniformOutput',0);
chem_rep=arrayfun(@(i) ['$<pre>x\(vox+' num2str(i-1) '*sz\)$<post>'],1:length(chems),'UniformOutput',0);

lines=regexprep(lines,chem_ref,chem_rep);


lines=cellfun(@(x) [x ';'], lines,'UniformOutput',0);

%% initializing some symbolics stuff

chem_str = strjoin(chems,' ');




% chem_str2 = strjoin(chems(1:N_slow),',');
if ~isempty(model_defs)
    def_str=strjoin(model_defs,[';' newline]);
else
    def_str='';
end

eval([sym_str ' ' chem_str ' ' newline def_str ';'])

eval([ 'assume([' strjoin([[model_vars']' model_pars chems]) ']>0)'])
eval([ 'assume([' strjoin([[model_vars']' model_pars chems]) ']>0)'])
% S_fast  = [-[pair_inds{:}]+[fast_inds{:}] [pair_inds{:}]-[fast_inds{:}]]; %only simple reversible complexation is supported right now :(
%this gives you all the slow variables
is_fast=~any(S_',1)&any(S_fast',1);


[rates_naive, rxn_naive] = rate_strings(chems(~is_fast),S_,rate_constants,S_cat);


%% ENUMERATING CONSTRAINTS
QSSA_defs = regexp(str,['(?:\n|^)QSS(?:A?)\(([ \t\f]*' name(2:end-1) '[ \t\f]*[\,])*' name '(?=\))'],'tokens');
QSSA_defs = [QSSA_defs{:}];
if ~isempty(QSSA_defs)
    QSSA_defs = QSSA_defs(cellfun(@(x) ~isempty(x),QSSA_defs));
    i_QSSA = cellfun(@(x) find(strcmp(x,chems),1),QSSA_defs);
else
    i_QSSA=[];
end
fast_chems = [QSSA_defs chems(is_fast)'];

is_fast(i_QSSA)=true;

elim =fast_chems;
elim_0=elim;

fast_eqns = eval(['[' strjoin(strcat('0==',[rates_naive{i_QSSA} rates_fast]),';') ']']);
fast_eqns_0 = fast_eqns;
con_str=[];
N_chem = length(chems);
N_fast = length(fast_eqns);

N_slow = length(chems)-N_fast;
N_elim_0 = length(elim);

p_elim_con={};
for i=1:N_con
    
    l=lcon(:,i);
    inds=l>0;
    con_str = [con_str strjoin(strcat(string(l(inds)),'*',chems(inds)'),'+')];
    
    p_elim_con{end+1}=chems(inds);
    
end



consrv_nm = strcat('cnsrv_',string(1:N_con)) ;
eval(['syms ' char(strjoin(consrv_nm,' '))])

eval(['assume([ ' char(strjoin(consrv_nm,', ')) ']>0)'])
consrv_eqns = eval(['[' char(strjoin(strcat(consrv_nm,'==',con_str),';')) ']']);
% consrv_defs = regexprep(string(consrv_eqns),[name '(?![A-z0-9]* ==) '],'$1(0)');
% consrv_reps = cellfun(@(x) x(2),  regexp(consrv_defs,'==','split'));

eqns=sym2cell([consrv_eqns; fast_eqns ]);

%% ELIMINATING VARIABLES
p_elim_fast = regexp(cellstr(string(fast_eqns)),name,'tokens');
p_elim_fast=cellfun(@(x) [x{:}],p_elim_fast,'UniformOutput',0);
p_elim_fast=cellfun(@(x) intersect(x,chems),p_elim_fast,'UniformOutput',0);

elim_con={};
elim_con_eqn={};

if N_elim_0<N_con %under specified
    
    
    eqns=fast_eqns;
    
    for e=fast_chems'
        ind=cellfun(@(pe) strcmp(e,pe), [p_elim_fast; p_elim_con'], 'UniformOutput', 0);
        contains = cellfun(@any,ind);
        take = find(contains,1);
        p_elim_fast(contains(1:N_fast)) = cellfun(@(pe) setdiff(pe,e, 'stable'), p_elim_fast(contains(1:N_fast)),'UniformOutput',0);
        p_elim_con(contains(N_fast+1:end)) = cellfun(@(pe) setdiff(pe,e, 'stable'), p_elim_con(contains(N_fast+1:end)),'UniformOutput',0);

        p_elim_fast(take)=[];
        eqns(take)=[];
    end
    
    p_elim = [p_elim_con'; p_elim_fast]; %p_elim_fast should be empty....
% if numel(p_elim)>1

% else
%     p_elim=1;
% end

    p_elim = cellfun(@(pe) intersect(pe,chems,'stable'),p_elim_con,'UniformOutput',0);
    eqns = sym2cell(consrv_eqns);
    
    while length(elim)~=N_con
        e=p_elim{1}{1};
        p_elim = cellfun(@(pe) setdiff(pe,e, 'stable'), p_elim,'UniformOutput',0);
        p_elim(1)=[];
        
        elim{end+1} = e ;
        elim_con_eqn{end+1} = eqns{1};
        elim_con{end+1} = e;
        
        eqns(1)=[];
        
    end
    consrv_eqns_elim = eval(['[' char(strjoin(string(elim_con_eqn),' ')) ']']);
else %over specified
    elim = elim(1:N_fast);
end
if size(elim,1)==1
    elim=elim';
end

N_elim = length(elim);
N_wp =  N_chem - N_elim;


warning ('off','symbolic:solve:SolutionsDependOnConditions');

if ~isempty(fast_chems)
    
    sol_fast_0 = eval(['solve( fast_eqns,[' strjoin(fast_chems,' ')  '])']);
    if length(fast_chems)~=1
        sol_fast_0 = struct2cell(sol_fast_0);
    else
        sol_fast_0 = {sol_fast_0};
    end
else
    elim_defs={};
    
end

%SOLVE THE CONSERVATION EQUATIONS
sol_consrv=eval(['solve( consrv_eqns_elim,[' strjoin(elim_con,' ')  '])']);
if length(elim_con)==1
    elim_defs =  strcat(elim_con{1},'=',string(sol_consrv));
    sol_rhs =  {sol_consrv'};
    consrv_subs =  sol_consrv;
else
    elim_defs = cellfun(@(e) strcat(e,'=',string(sol_consrv.(e))),elim_con)';
    sol_rhs = struct2cell(sol_consrv);
    consrv_subs = cell2sym(struct2cell(sol_consrv));
    sol_consrv = struct2cell(sol_consrv);
end
consrv_refs = strcat('(?<=(?:^|[\+\- \*\(]))(',elim_con,')(?=(?:$|[\+\- \*\.\)]))')';
% fast_refs = strcat('(?<=(?:^|[\+\- \*\(]))(',chems(is_fast),')(?=(?:$|[\+\- \*\.\)]))')';

% fast_reps =regexprep(string(sol_rhs{1:N_fast}),slow_refs, slow_init_reps);
% consrv_arr = eval(strcat('[',strjoin(string(sol_consrv)),']'));
% fast_arr = eval(strcat('[',strjoin(string(fast_chems)),']'));
if ~isempty(fast_chems)
    fast_eqns = subs(fast_eqns, str2sym(elim_con'), consrv_subs);
    sol_fast=eval(['solve( fast_eqns,[' strjoin(fast_chems,' ')  '])']);
    if length(fast_chems)==1
        elim_defs = [ {strcat(fast_chems{1},'=',string(sol_fast))}; elim_defs];
        sol_rhs = [{sol_fast}; sol_rhs];
        sol_fast={sol_fast};
    else
        elim_defs = [cellfun(@(e) strcat(e,'=',string(sol_fast.(e))),fast_chems); elim_defs];
        sol_rhs =  [struct2cell(sol_fast); sol_rhs];
        sol_fast = struct2cell(sol_fast);
    end
else
    sol_fast={};
    %     elim_defs={};
    %      sol_rhs = {};
end
warning ('on','symbolic:solve:SolutionsDependOnConditions');

consrv_arr = eval(strcat('[',strjoin(string(sol_consrv)),']'));
fast_chem_arr = eval(strcat('[',strjoin(string(fast_chems)),']'));
fast_arr = eval(strcat('[',strjoin(string(sol_fast)),']'));

tt=subs(consrv_arr,fast_chem_arr,fast_arr);
sol_rhs(N_fast+1:end) =  sym2cell(tt(1:N_con-N_fast));

cellfun(@(e) disp(['Eliminating: ' e]),elim_defs)
elim_str = strjoin(elim_defs,newline);
if ~isempty(S_fast)
    is_slow = ~any(S_fast');
else
    is_slow = true(size(chems));
end
is_elim = cellfun(@(c) any(strcmp(c,elim)),chems);



% f_slow = cellfun(@(c) ['f_' c], {chems{~is_elim}}, 'UniformOutput', false);

f_chems = cellfun(@(c) ['f_' c], chems, 'UniformOutput', false);


eval([ ' syms ' strjoin(f_chems,' ') ';']);
eval([ 'assume([' strjoin([[model_vars']' model_pars]) ']>0)']);
eval(strcat(' assume([', strjoin(f_chems), "],'real')"));
eval(strcat(' assume([', strjoin(chems), "],'real')"));

%% Computing GAMMA

% Gamma = eval([ ' [' strjoin( cellfun(@(aff, pair ) ['simplify(' aff '*' pair ',"Steps",10)'],fast_affinity, fast_pair,'UniformOutput',0),';') ']']   );
if length(fast_eqns)>=1
    Gamma=eval(strcat("[",strjoin(string(sol_fast_0)),"]"))';
else
    Gamma=[];
end
Gamma_0=Gamma;
Gamma_simp = Gamma;
i=0;
% nm = ['sigma0__' int2str(i)];
% [Gamma_simp,sigma__rep] = subexpr(Gamma_simp,nm);

%% COMPUTING J_GAMMA
J_gamma=arrayfun(@(gi) cellfun(@(j) simplify(diff(gi,j),'Steps',10),{chems{~is_fast}},'UniformOutput',0),Gamma_0,'UniformOutput',false)';
if ~isempty(J_gamma)
    J_gamma = [J_gamma{:}];
    J_gamma = [J_gamma{:}];
    J_gamma=reshape(J_gamma,[N_slow,size(Gamma,1)])';
end
J_gamma_0 = J_gamma;
%
%


big = [Gamma_0 J_gamma];
i=0;
nm = ['subs__' int2str(i)];

sigma__reps={};
if ~isempty(big)
    [big_simp,sigma__rep] = subexpr(big,nm);
    if ~isempty(sigma__rep)
        
        while ~isempty(sigma__rep)
            
            
            sigma__reps{end+1}=[nm  ' = ' char(simplify(sigma__rep,'Steps',10))];
            
            i=i+1;
            nm = ['subs__' int2str(i)];
            [big_simp, sigma__rep] = subexpr(big_simp,nm);
            
            
        end
        
    end
    
    big_simp = simplify(big_simp);
    if simp
        J_gamma = big_simp(:,2:end);
        Gamma = big_simp(:,1);
    end
end



% fast_pair_sym = eval(['[' strjoin(fast_pair) ']'])';
% aff_simp =  Gamma ./ fast_pair_sym;



%% setting up the liner system to determine reactions rates

lcon_fast = lcon(is_fast,:);
if N_fast>1
    i_con_fast = any( lcon_fast > 0 );
else
    i_con_fast =  lcon_fast > 0 ;
end
N_con_fast = nnz(i_con_fast);

% m0 = sym('m0', [N_con_fast N_slow]);

j_gam = sym('J_gamma_', [N_fast N_slow]);
if ~isempty(J_gamma)
    %     m0( J_gamma == 0 )=0;
    
    j_gam( J_gamma == 0) =0;
end


m11=j_gam;

lcon_fast=lcon_fast(:,i_con_fast);
lmix = lcon(~is_fast,i_con_fast)';
lslow_0 = lcon(~is_fast,~i_con_fast)';
% for i=1:N_con_fast
%     con_fast=lcon_fast(:,i)~=0;
%     if any(con_fast)
%         m0(i,:)=lmix(i,:)+sum(J_gamma(con_fast,:),1);
%     end
% end

l_sf=sym(lmix(1:N_con_fast,:));
for i=1:N_con_fast
    l_sf(i,:)=l_sf(i,:)+sum((lcon_fast(:,i)'.*j_gam')');
end
% l_sf=(lcon_fast'.*j_gam)+lmix(1:N_con_fast,:);
% b__0 = eval(['[' strjoin( f_slow,'; ') ']'] );
% for i=1:size(lslow,1)
% % irep =  find(any(m10(mask,:).*lslow(i,:),2),1);
% % mask
% % m10(irep,:) = lslow(i,:)
% end

% is_slow = ~is_elim;
is_solo = any(lmix( sum(abs(lmix),2)==1,:),1);
i_non_fast = find(~is_fast);
ind = is_slow&~is_fast;

eye_slow_0= diag(ind,0);
eye_slow_0 = eye_slow_0(ind,~is_fast);
% if ~isemtpty(i_non_fast(is_solo))
eye_slow_0 = eye_slow_0(~any(i_non_fast(is_solo) == find(ind)',2),:);
%finding a way to express our system that isnt undetermined
A_mat=[lslow_0; eye_slow_0]';
[A_rref,p_A]=rref(A_mat);
A_li_rows = A_mat(:,p_A)';
if size(A_li_rows,1)+N_con_fast>N_slow
    A_li_rows=A_li_rows(1:N_slow-N_con_fast,:);
elseif size(A_li_rows,1)+N_con_fast<N_slow
    error('Underdetermined slow sub-system, try removing some fast reactions.')
end

mask_slow_0 = sum(A_li_rows~=0,2)==1;

% i_non_fast = find(~is_fast);
mask_non_elim = any(i_non_fast==find(~is_elim)',1);
% i_slow_0 = i_non_fast(mask_slow_0);

i_0 = mod(find(A_li_rows(mask_slow_0,:)')-1,N_slow)'+1;


ij_slow = mod(find(A_li_rows(mask_slow_0,:)')-1,N_slow)+1;
f__0 = eval([ '[' strjoin(strcat('f_', chems )) ']']);
b__0 =  eval([ '[' strjoin(strcat('f_', chems(~is_fast) )) ']']);

b__0(:) =  0;
inds= i_non_fast(ij_slow);
b__0(mask_slow_0) = f__0(inds);



f_mix = [A_li_rows;l_sf]\[b__0]';
% f_mix2 = eval(['[m10;m0]\[' strjoin( f_slow,'; ') ';' strjoin(cellstr(string(zeros(1,size(J_gamma,1)))),'; ')  ']']);

% m100 = A_li_rows(mask_slow_0,:);
%
ij_non_fast = i_non_fast(ij_slow);



f_mix_simp = subexpr_simplify(simplify(simplify([f_mix; j_gam*f_mix],'Steps',20),'Steps',20),'subs2__')

if simp
    f_mix=f_mix_simp;
end


f_fast_simp = subexpr_simplify(simplify(f_fast,'Steps',20),'subs3__');




warning ('off','symbolic:sym:isAlways:TruthUnknown');
non_zero = ~arrayfun(@(m) isAlways(j_gam(m)==0) || isAlways(j_gam(m)==1),1:numel(j_gam));
warning ('on','symbolic:sym:isAlways:TruthUnknown');

m1_gamma=j_gam(non_zero);
m0=J_gamma(non_zero);

predefs = arrayfun(@(i) [char(m1_gamma(i)) '=' char(m0(i))],1:numel(m1_gamma),'UniformOutput',false);



rxn_rates=cell(size(S_,2),1);
for i=1:size(S_,2)
    r=-S_(:,i);
    r(r<0)=0;
    inds = r>0;
    terms = strcat(chems(inds),cellstr(repmat('.^',[nnz(inds),1]))',cellstr(string(r(inds)))');
    terms = regexprep(terms,'\.\^1$',''); %remove exponent 1's from rate computation
    rate_str = [ rate_constants{i} '.*' strjoin(terms,'.*')];
    if any(S_cat(:,i))
        rate_str = [ rate_str '.*' strjoin(chems(S_cat(:,i)),'.*') ];
    end
    rxn_rates{i} = rate_str;
end




elim_refs = nameref(elim);
elim_reps = strcat('(',string(sol_rhs),')');

rxn_rates = regexprep(rxn_rates,elim_refs,elim_reps);

chem_rates_slow={};
f_slow={};
for chem_ind = ij_non_fast
    %     chem_ind = find(m10(i,:),1);
    S_chem = S_(chem_ind,:);
    inds = find(S_chem);
    terms = strcat(cellstr(num2str(S_chem(inds)')),repmat('*(',[length(inds),1]),rxn_rates(inds),repmat(')',[length(inds),1]));
    terms = regexprep(terms,'[^0-9\.\-\+]*1\*',''); %remove multiplication by 1's from rate computation
    sum_terms = strjoin(terms,'+'); % sum terms
    sum_terms = regexprep(sum_terms,'+-','-');% remove +-, replace with -
    if length(sum_terms)==0
        sum_terms='0';
    end
    chem_rates_slow{end+1} = ['f_' chems{chem_ind} ' = ' sum_terms];
    f_slow{end+1} = sum_terms;
    
end



f_slow = simplify(str2sym(f_slow));

f_non_elim={};
for chem_ind = find(~is_elim)
    %     chem_ind = find(m10(i,:),1);
    S_chem = S_(chem_ind,:);
    inds = find(S_chem);
    terms = strcat(cellstr(num2str(S_chem(inds)')),repmat('*(',[length(inds),1]),rxn_rates(inds),repmat(')',[length(inds),1]));
    terms = regexprep(terms,'[^0-9\.\-\+]*1\*',''); %remove multiplication by 1's from rate computation
    sum_terms = strjoin(terms,'+'); % sum terms
    sum_terms = regexprep(sum_terms,'+-','-');% remove +-, replace with -
    if length(sum_terms)==0
        sum_terms='0';
    end
%     rates_slow{end+1} = ['f_' chems{chem_ind} ' = ' sum_terms];
    f_non_elim{end+1} = sum_terms;
    
end


f_non_elim = simplify(str2sym(f_non_elim));

disp('Reaction Rates:')
disp(strjoin(strcat('d',chems(~is_elim),'/dt=',string(f_non_elim)),newline))

consume_fmix_fun(S_,chems,rate_constants,S_cat,elim,sol_rhs,consrv_eqns,code,...
is_fast,is_slow,f,elim_str,ij_non_fast,simplify,is_elim,pre,post,spatial_vars,...
model_defs,sigma__reps,predefs,sigma2__reps,f_mix,chem_ref,N_fast,sol_fast_0,...
par_refs,par_reps,consrv_nm,m1_gamma,m0,f__0,model_vars,model_var_defs,...
mask_non_elim,ref,par_defs,model_par_vals,model_pars,name,i_0,vox,N_slow)
end

