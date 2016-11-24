function [patch affinerough sample]=densesample_rough(img,affinere,sz)
sbin=8;
offset=[-30:2:30];
[offsetx offsety]=meshgrid(offset,offset);
num=(length(offsetx(:)));
affine=repmat(affinere,1,num);
offset=zeros(6,num);
offset(1:2,:)=[offsetx(:)';offsety(:)'];
affinerough=affine+offset;
indexnum=0;
for i=1:3
    for j=1:16
        indexnum=indexnum+1;
        radius=30+(i-1)*10;
        theta=j*2*pi/16;
        xcoe(indexnum)=round(affinere(1)+radius*cos(theta));   
        ycoe(indexnum)=round(affinere(2)+radius*sin(theta)); 
    end
end
affineaddi=repmat(affinere,1,indexnum);
affineaddi(1:2,:)=[xcoe;ycoe];
affinerough=[affinerough affineaddi];

patch=warpimg(double(img),affparam2mat(affinerough),sz);
samplelength=size(affinerough,2);
sample=zeros(samplelength,324);
for i=1:samplelength
    feat = features_gray(uint8(patch(:,:,i)), sbin); 
    feat = feat(:,:,1:9) + feat(:,:,10:18);
    sample(i,:)=feat(:);
end

