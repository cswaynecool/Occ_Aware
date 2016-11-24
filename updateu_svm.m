function [w,SV_u,SVindex_u]=updateu_svm(uncertain,postem,negtem,frameNum,SV_v,SVindex_v,SV_u,SVindex_u,w,part,turn,affine,SampleNum,sample,sampletotal,npart,negindex,posindex,sz)
for i=1:npart  
     if part{i}.child==0
    label_vector=0;
    pos{i}=sample{i}(posindex{i},:);
    neg{i}=sample{i}(negindex{i},:);
    pos{i}=repmat(pos{i},size(neg{i},1),1);
        k=sample{i}(posindex{i},:);
        kk=sample{i}(negindex{i},:);
    if i~=npart+1&&frameNum>2
         pos{i}=[pos{i};SV_u{i}(1:SVindex_u{i},:)]; neg{i}=[neg{i};SV_u{i}(SVindex_u{i}+1:end,:)];
    else
         pos{i}=[pos{i};SV_v(1:SVindex_v,1:144)]; neg{i}=[neg{i};SV_v(SVindex_v+1:end,1:144)];
    end
    length1=size(pos{i},1);
    length2=size(neg{i},1);
    lengthtotal=size(pos{i},2);
                  label_vector(1:length1)=1; label_vector(length1+1:length1+length2)=0;
                  train_data=cat(1,pos{i},neg{i}); 
                  alpha = svmtrain(label_vector', train_data, '-c 1 -t 0');
               
                  if i~=npart+1
                  w(lengthtotal+(i-1)*lengthtotal+1:lengthtotal+i*lengthtotal)=sum( repmat(alpha.sv_coef,1,size(pos{i},2)).*alpha.SVs);
                  else 
                  w(1:lengthtotal)=sum( repmat(alpha.sv_coef,1,size(pos{i},2)).*alpha.SVs);
                  end
                  SV_u{i}=alpha.SVs; SVindex_u{i}=alpha.nSV(1);
     end
end