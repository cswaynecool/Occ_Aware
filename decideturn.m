function turn=decideturn(part,npart)
for i=1:npart+1
    if part{i}.parent==0
        root=i;
    end
end
for i=1:npart
turn(i)=digui(part,i);   
end

function [level]=digui(part,root) 
       k=part{root}.parent;
        
       if k==0
           level=1;
       else
       level=digui(part,k)+1; 
       end
       
0;