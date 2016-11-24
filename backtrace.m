function part=backtrace(part,turn)
levelmax=max(turn);
for i=1:levelmax
     if i==1 
         node= turn==1;
         [~,part{node}.sel]=max(sum(part{node}.msg,2)); 
     else
          nodetotal=find(turn==i);     
          for j=1:length(nodetotal)
              node=nodetotal(j);
              parentnode=part{node}.parent;
              sel=part{parentnode}.sel;
              part{node}.sel=part{node}.record(sel);
          end
     end
end
       
       