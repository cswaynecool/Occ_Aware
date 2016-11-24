function [part, score]=domessagepass(storeneg,mask,sumhoglength,uncertain,frameNum,turn,w,sampletotal,sample,part,npart,disvec,affine,SampleNum,hiddenpart)
%% the sum-max message passing algorithm
%% the mapping between beteen the edges and nodes, e.g., map(4,1) means the index of the edge between nodes 4 and 1.
map=[0 7 8 4 1 0 0 0; 7 0 9 5 0 2 0 0;8 9 0 6 0 0 3 0; 4 5 6 0 0 0 0 10; 1 0 0 0 0 0 0 0;0 2 0 0 0 0 0 0;0 0 3 0 0 0 0 0; 0 0 0 10 0 0 0 0];
k1=size(sampletotal,2);
k=size(sample{1},2); 
scoretotal=sampletotal*(w(1:k1))*0.3;
indexbase=sumhoglength(npart+1);
score=cell(1,npart+1);
frameindex=mod(frameNum+9,10)+1;
maxscore=cell(1,npart+1);  
    
for i=1:npart
   if i==npart+1
       v=w(1:k1);
   else
       v=w(k1+(i-1)*k+1:k1+i*k);
   end  
    maxscore{i}=-1;
     for ite=1:1  
       frameindex1=mod(frameNum-ite+10,10)+1;
            if ~isempty(storeneg{i,frameindex1})
                  maxscore{i}=max(maxscore{i},max(storeneg{i,frameindex1}*v));
            end
     end
    if frameNum>2  
        score{i}=sample{i}*v;  
       if mask{i}(frameindex)==2
           score{i}=max(score{i},maxscore{i});
       end
       
       
    else
       score{i}=sample{i}*v;
    end
end
score{npart+1}=scoretotal;

levelmax=max(turn); % obtain the maximum tree depth.

if frameNum>2
    for i=npart+2:2*npart+2
       part{i}.msg=hiddenpart{i-npart-1}.msg;
    end
end

for i=levelmax:-1:1
    nodetotal=find(turn==i); % get the indexes for nodes in current layer
    for j=1:length(nodetotal)
        node=nodetotal(j); 
        if part{node}.child==0 
           part{node}.msg=score{node};
        else
            childvec=part{node}.child;
            for childi=1:length(childvec)  
                for nodei=1:SampleNum(node)    
                 
                       k=childvec(childi);
                       edgein=map(node,k); 
                       index=indexbase+(edgein-1)*4+1;
                       if node<k
                              dx=affine{node}(1,nodei)-affine{k}(1,:)-disvec{node,k}(1);
                              dy=affine{node}(2,nodei)-affine{k}(2,:)-disvec{node,k}(2);
                       else
                              dx=affine{k}(1,:)-affine{node}(1,nodei)-disvec{k,node}(1);
                              dy=affine{k}(2,:)-affine{node}(2,nodei)-disvec{k,node}(2);
                       end
                       dx=dx'; dy=dy';
                      
                        disvec1=0.0055*[dx dx.^2 dy dy.^2];  
                        if  4<childvec(childi)&&childvec(childi)<10
                                disvec1=0.001*[dx dx.^2 dy dy.^2];  
                                if childvec(childi)==8
                                    disvec1=0.001*[dx dx.^2 dy dy.^2];
                                end
                                if uncertain(node)==1
                                    disvec1=0.000*[dx dx.^2 dy dy.^2];
                                end
                        end
                           
             [part{node}.msg(nodei,k), part{k}.record(nodei)]=max(disvec1*w(index:index+3)+sum(part{k}.msg,2));  
             part{node}.msg(nodei,node)=score{node}(nodei);
                end
            end
        end
    end
end    
score{npart+1}=0.5*sum(part{npart+1}.msg(:,1:3),2)+part{npart+1}.msg(:,4);
end

