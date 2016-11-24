function [w,SV_v,SVindex_v,SV_u,SVindex_u]=updatew_svm(uncertain,postem,negtem,SV_v,SVindex_v,SV_u,SVindex_u,frameNum,w,disvec,part,turn,affine,SampleNum,sample,sampletotal,npart,sz)
%% we train the model here
   maxlevel=max(turn);
   
      for level=maxlevel:-1:1
         nodetotal=find(turn==level);
         for i=1:length(nodetotal)
             node=nodetotal(i);
             posindex{node}=[];
             negindex{node}=[];
             posindex{node}=part{node}.sel;
            for nodei=1:1 
               dis=sum((affine{node}(1:2,nodei)-affine{node}(1:2,part{node}.sel)).^2); 
                if dis>100
                negindex{node}=[negindex{node} nodei];
                end
            end
         end
      end
%% two-stage training     
if frameNum==2
     [w,SV_v,SVindex_v,SV_u,SVindex_u]=updatev_svm(uncertain,postem,negtem,SV_v,SVindex_v,SV_u,SVindex_u,frameNum,w,disvec,part,turn,affine,SampleNum,sample,sampletotal,npart,negindex,posindex,sz);
else 
     [w,SV_v,SVindex_v,SV_u,SVindex_u]=updatev_svm(uncertain,postem,negtem,SV_v,SVindex_v,SV_u,SVindex_u,frameNum,w,disvec,part,turn,affine,SampleNum,sample,sampletotal,npart,negindex,posindex,sz);
     [w,SV_u,SVindex_u]=updateu_svm(uncertain,postem,negtem,frameNum,SV_v,SVindex_v,SV_u,SVindex_u,w,part,turn,affine,SampleNum,sample,sampletotal,npart,negindex,posindex,sz);
end