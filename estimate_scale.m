function affinere=estimate_scale(affinere,img,w)
n=60;
sz=[64 64];
affsig=[0,0,1,.00,.000,.000];
affine=repmat(affinere,1,n);
randMatrix=zeros(6,n);
for i=1:60
 randMatrix(3,i)=0.001*(i-30)*2/3;
end
sbin=8;
affinerough = affine + randMatrix.*repmat(affsig(:),[1,n]);
affinerough(:,end+1)=affinere;
patch=warpimg(double(img),affparam2mat(affinerough),sz);
for i=1:n+1
    feat = features_gray(uint8(patch(:,:,i)), sbin); 
    feat = feat(:,:,1:9) + feat(:,:,10:18);
    sample(i,:)=feat(:);
end    
[ignore,index]=max(sample*w);
affinere=affinerough(:,index);

