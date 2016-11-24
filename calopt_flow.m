function [px,py,uncertain,optmapx,optmapy,optconfidence]=calopt_flow(img,preimg,affinere,npart,sz)
%% we compute the optical flow between two successive frames here
[imghei,imgwid]=size(img(:,:,1));
optmapx=zeros(imghei,imgwid); 
optmapy=zeros(imghei,imgwid);
optconfidence=10*ones(imghei,imgwid); 
uncertain=zeros(1,4); % a variable indicating whether the computed optical flow is reliable
height=affinere{npart+1}(5)*affinere{npart+1}(3)*sz(1);
width=affinere{npart+1}(3)*sz(1);
lk(0)
rangex=floor(affinere{npart+1}(1)-width/2-20):floor(affinere{npart+1}(1)+1*width/2+20);
rangey=floor(affinere{npart+1}(2)-1*height/2-20):floor(affinere{npart+1}(2)+1*height/2+20);
[gridx,gridy]=meshgrid(rangex,rangey);
[lengthx,lengthy]=size(gridx);
grid(1,:)=reshape(gridx,[1 lengthx*lengthy]); grid(2,:)=reshape(gridy,[1 lengthx*lengthy]);
lk(0)
a=lk(2,preimg,img,grid,grid);
   for i=1:npart+1   % estimate the optical flow for each fragment
    height=affinere{i}(5)*affinere{i}(3)*sz(1);
    width=affinere{i}(3)*sz(1);
    index1=(affinere{i}(1)-width/2<grid(1,:)).*(affinere{i}(1)+width/2>grid(1,:)).*(affinere{i}(2)-height/2<grid(2,:)).*(affinere{i}(2)+height/2>grid(2,:));
    index2=abs(a(3,:))<2.*(~isnan(a(1,:)));
    index=index1.*index2;

    if (sum(index)<150)&&i~=(npart+1)   % tell if the estimated optical flow is reliable
        uncertain(i)=1;
    elseif (sum(index)<700)&&i==(npart+1)  % tell if the estimated optical flow is reliable
        uncertain(i)=1;
    end
       
    if sum(index)~=0
    px{i}=sum(a(1,index>0)-grid(1,index>0))/sum(index);
    py{i}=sum(a(2,index>0)-grid(2,index>0))/sum(index); 
    else
       px{i}=0;
       py{i}=0;
    end
   end

index1=(a(1,:)>0.9).*(a(2,:)>0.9).*(a(1,:)<imgwid).*(a(2,:)<imghei)>0;
index=((round(a(1,index1))-1)*imghei+round(a(2,index1)));
optmapx(index)=gridx(index1)-a(1,index1);
optmapy(index)=gridy(index1)-a(2,index1);
optconfidence(index)=a(3,index1);




    







