function [t,y]=timecourse(f,func_str,pre_defs)

global active_model

if ~isempty(active_model) 
    base_dir = strcat('../_',active_model);
else
    base_dir = '..';
end


load(strcat(base_dir,'/results/',f));

plotting=true;
N_steps=size(Results,4);
% initialize_pic()
tic();
plot_accum={};

for i=1:iter
   x=Results(:,:,2:end,i);
   time=Times(i);
   eval_model;
   if nargin==3
       eval(pre_defs);
   end

   plot_accum{end+1}=eval(func_str);
%    drawnow()
end

t=Times(1:iter);
y=cell2mat(plot_accum');




end