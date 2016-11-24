function [pos,neg]=densesample_getsample_frameone(patch,affine,affinere,sample)
%% obtain samples from the first frame
sbin=8; 
neg=[];
samplelength=size(affine,2); 
tmp=repmat(affinere,[1,samplelength]);
dis=sqrt(sum(  (affine(1:2,:)-tmp(1:2,:)).^2));
[ignore,index]=min(dis);
pos=sample(index,:);
negindex=0;
for i=1:10:samplelength
    
     dis=sqrt(sum(  (affine(1:2,i)-affinere(1:2)).^2)); 
     if dis<1e-6
    elseif (dis>8&&dis<10)||(13<dis&&dis<16)||(21<dis&&dis<25)
        negindex=negindex+1;
        neg(negindex,:)=sample(i,:);
     end
end
if isempty(neg)
    for i=1:10:samplelength
     dis=sqrt(sum(  (affine(1:2,i)-affinere(1:2)).^2)); 
       if dis<1e-6
       elseif (dis>8&&dis<50)||(13<dis&&dis<16)||(21<dis&&dis<25)
          negindex=negindex+1;
          neg(negindex,:)=sample(i,:);
       end
    end
end
pos=repmat(pos,negindex,1);
       
