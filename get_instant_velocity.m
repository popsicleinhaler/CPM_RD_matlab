function v = get_instant_velocity(f,iters,n0)

%%load in the results
load([ f]);
iter=min(iter,length(Times));

if nargin==1 || isempty(iters)
    iters=1:iter;
end

iters=iters(iters<=iter);

center=center(:,iters);
Times=Times(iters);

if nargin<3
    n=1;
end
M=size(center,2);

dr=center(:,1:n0:M-n0)-center(:,1+n0:n0:M);

v= dr./(Times(1+n0:n0:end)-Times(1:n0:M-n0));

net_vel=sqrt(sum((center(:,1)-center(:,end)).^2,1))/(Times(end)-Times(1))

end

