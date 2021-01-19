T_integration = cpmstep;
while time<Ttot
    A=nnz(cell_mask); %current area
    cell_inds(1:A)=find(cell_mask); %all cell sites padded with 0s (initially)
    
    while (time-last_time)<Ttot
        

        
%         x0=x;
%         detect_bndrys
%         disp('tryng SSA')    
        %run the SSA
       
        FVM_integrator_2SBF_slim
 
        
        
        if time>=lastcpm+cpmstep
            
            for kk=1:(2*Per)/cpmsteps %itterates CPM step Per times
%                 disp('doing CPM')
                try
                    CPM_step
                catch err
                    rethrow(err)
%                     time=Ttot;
                    break;
                end
                
                detect_bndrys
                
%                 if sum(x(:))~=d0
%                     disp(['molecules changed, delta = ' num2str(sum(x(:))-d0) ])
%                 end
            end
            
            enumerate_diffusion %recalcluates diffusable sites
            lastcpm=time;
            cpmcounter=cpmcounter+1;
        end
                
        if time>=lastplot+picstep || time==lastcpm % takes video frames
 
            if cpmcounter==cpmsteps*cpm_wait
              pic
              lastplot=time; 
            
 
                if plotting
                    gif
                end
                if ~isempty(getCurrentTask())
                    disp([num2str(copyNum) ': B=' num2str(B_1) ', t=' num2str(time)])
                end
                save_results
                cpmcounter=0;
            end
            
            
        end
        
    end
    
    last_time=time;
    
    
    
    enumerate_diffusion %recaucluates diffusable sites
end