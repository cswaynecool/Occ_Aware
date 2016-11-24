function [w,SV_v,SVindex_v,SV_u,SVindex_u]=updatev_svm(uncertain,postem,negtem,SV_v,SVindex_v,SV_u,SVindex_u,frameNum,w,disvec,part,turn,affine,SampleNum,sample,sampletotal,npart,negindex,posindex,sz)
map=[0 7 8 4 1 0 0 0; 7 0 9 5 0 2 0 0;8 9 0 6 0 0 3 0; 4 5 6 0 0 0 0 10; 1 0 0 0 0 0 0 0;0 2 0 0 0 0 0 0;0 0 3 0 0 0 0 0; 0 0 0 10 0 0 0 0];
hoglengthtotal=size(sample{npart+1}(1,:),2);
sumhoglength(1)=hoglengthtotal;
for i=1:npart+1
    hoglength(i)=size(sample{i}(1,:),2);
    if i>1
        sumhoglength(i)=hoglength(i-1)+sumhoglength(i-1); 
    end
end


maxlevel=max(turn);
for level=1:maxlevel
    nodetotal=find(turn==level); % we find the nodes in the current depth
    for nodei=1:length(nodetotal)
        node=nodetotal(nodei);
        child=part{node}.child;
        if child~=0
                 SV_pos=SV_u{node}(1:SVindex_u{node},:);
                 SV_neg=SV_u{node}(SVindex_u{node}+1:end,:);
            for childi=1:length(child)   
                if node<child(childi)&&~isempty(SV_u{node})
                     num=size(SV_v{node,child(childi)}(SVindex_v{node,child(childi)}+1:end,:),1);
                     if size(SV_pos,1)-SVindex_v{node,child(childi)}<0
                      SV_pos=[SV_pos SV_v{node,child(childi)}(1:size(SV_pos),:)];
                     else
                     SV_pos=[SV_pos [SV_v{node,child(childi)}(1:SVindex_v{node,child(childi)},:);zeros(size(SV_pos,1)-SVindex_v{node,child(childi)},4)]];
                     end
                      if num>size(SV_neg,1)
                       SV_neg=[SV_neg SV_v{node,child(childi)}(end-size(SV_neg,1)+1:end,:)];
                      else
                       SV_neg=[SV_neg [SV_v{node,child(childi)}(SVindex_v{node,child(childi)}+1:end,:);zeros(size(SV_neg,1)-num,4)]];
                      end
                elseif child(childi)<node&&~isempty(SV_u{node})
                     num=size(SV_v{child(childi),node}(SVindex_v{child(childi),node}+1:end,:),1); 
                       if size(SV_pos,1)-SVindex_v{child(childi),node}<0
                          SV_pos=[SV_pos SV_v{child(childi),node}(1:size(SV_pos),:)];
                       else
                          SV_pos=[SV_pos [SV_v{child(childi),node}(1:SVindex_v{child(childi),node},:);zeros(size(SV_pos,1)-SVindex_v{child(childi),node},4)]];
                       end
                       if num>size(SV_neg,1)
                          SV_neg=[SV_neg SV_v{child(childi),node}(end-size(SV_neg,1)+1:end,:)];
                       else
                          SV_neg=[SV_neg [SV_v{child(childi),node}(SVindex_v{child(childi),node}+1:end,:);zeros(size(SV_neg,1)-num,4)]];
                       end
                end
            end
            [pos,neg]=catfeature(node,postem,negtem,child);  %obtain the concatenated training samples.
           
            pos=[pos; SV_pos]; neg=[neg; SV_neg];
           %% begin training, good luck!!!
            length1=size(pos,1); length2=size(neg,1);
            label_vector=zeros(1,length1+length2);
            label_vector(1:length1)=1; label_vector(length1+1:length1+length2)=0;
            train_data=cat(1,pos,neg); 
            if ~isempty(label_vector)
            alpha = svmtrain(label_vector', train_data, '-c 1 -t 0');
             
             SV_u{node}=alpha.SVs(:,1:hoglength(node));  SVindex_u{node}=alpha.nSV(1); 
             
             for childi=1:length(child)
                 if child(childi)>node
                     SV_v{node,child(childi)}=alpha.SVs(:,hoglength(node)+(childi-1)*4+1:hoglength(node)+childi*4);
                     SVindex_v{node,child(childi)}=alpha.nSV(1);
                 else
                     SV_v{child(childi),node}=alpha.SVs(:,hoglength(node)+(childi-1)*4+1:hoglength(node)+childi*4); 
                     SVindex_v{child(childi),node}=alpha.nSV(1);
                 end
             end
           if ~isempty(pos)||(~isempty(alpha.SVs))
            v=sum( repmat(alpha.sv_coef,1,size(pos,2)).*alpha.SVs);  
           end
                
                               if node==npart+1
                                    w(1:hoglength(node))=v(1:hoglength(node));
                               else
                                    try
                                      w(sumhoglength(node)+1:sumhoglength(node+1))=v(1:hoglength(node));
                                    catch
                                        a=1;
                                    end
                               end
                                  
                   for i=1:length(child)
                       index=map(node,child(i));
                       try
                       tmp=v(hoglength(node)+(i-1)*4+1:hoglength(node)+4*i);
                       catch
                          w(sumhoglength(npart+1)+(index-1)*4+1:sumhoglength(npart+1)+index*4)=0;
                          continue;
                       end
                           tmp(4)=min(tmp(4),0);tmp(2)=min(tmp(2),0);
                        w(sumhoglength(npart+1)+(index-1)*4+1:sumhoglength(npart+1)+index*4)=tmp;
                   end
            end
        end
    end
end

