function fh = pdepe_fun()
    N_species = 0;
    N_rx = 0;
    D = 0;
    N_slow = 0;
    chems={};


    initialize_chem_params
    D=D(1:N_slow)';
    c0=ones(N_slow,1);
    
    function  [c,f,s] = rhs_tot(x,t,u,dudx)
        c=c0;
        f=D.*dudx;
        s=rhs_fun_tot(t,u);     
        s=s(1:N_slow);
    end

    fh = @rhs_tot;

end

