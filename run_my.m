function [res res1 res2 res3]=run_my(subS)
%% the main function
affsig=[4,4,.05,.0005,.0005,.001];
type=1; npart=3;
init_rect=subS.init_rect;
sz=[64 64];
p=[init_rect(1)+init_rect(3)/2, init_rect(2)+init_rect(4)/2, init_rect(3), init_rect(4), 0];
%% the postion for the holistic target
affinetotal=[p(1), p(2), p(3)/sz(1), p(5), p(4)/p(3), 0];
height=affinetotal(5)*affinetotal(3)*sz(1);
width=affinetotal(3)*sz(1);
minx=p(1)-width/2; maxx=p(1)+width/2; miny=p(2)-height/2; maxy=p(2)+height/2;
bbtotal=[miny,minx,maxy,maxx];
if type==1  
      if width<1.7*height  % determine if we divide the fragments vertically or horizontally
       for i=1:npart
          if i==1
              miny=p(2)-height/2; maxy=p(2)-height/6; minx=p(1)-width/2; maxx=p(1)+width/2;   % initialize the positions for fragment 1
              bb{1}=[miny,minx,maxy,maxx];
          elseif i==2
              miny=p(2)-height/6; maxy=p(2)+height/6; minx=p(1)-width/2; maxx=p(1)+width/2;  % initialize the positions for fragment 2
              bb{2}=[miny,minx,maxy,maxx];
          elseif i==3
              miny=p(2)+height/6; maxy=p(2)+height/2; minx=p(1)-width/2; maxx=p(1)+width/2; % initialize the positions for fragment 3
              bb{3}=[miny,minx,maxy,maxx];
          end
       end    
      else
        for i=1:npart
          if i==1
              miny=p(2)-height/2; maxy=p(2)+height/2; minx=p(1)-width/2; maxx=p(1)-width/6;  % initialize the positions for fragment 1 
              bb{1}=[miny,minx,maxy,maxx];
          elseif i==2
              miny=p(2)-height/2; maxy=p(2)+height/2; minx=p(1)-width/6; maxx=p(1)+width/6; % initialize the positions for fragment 2
              bb{2}=[miny,minx,maxy,maxx];
          elseif i==3
              miny=p(2)-height/2; maxy=p(2)+height/2; minx=p(1)+width/6; maxx=p(1)+width/2; % initialize the positions for fragment 3
              bb{3}=[miny,minx,maxy,maxx];
          end
        end    
       end
end

 postem=cell(4,8);
 negtem=cell(4,8);
 storepos=cell(1,npart+1);
 storeneg=cell(npart+1,10);
 datahistory=cell(1,npart);

 maxscore=cell(1,npart+1);
 posstart=zeros(4,8,5);
 posend=zeros(4,8,5);
 negstart=zeros(4,8,5);
 negend=zeros(4,8,5);
 mask=cell(1,npart+1);
 selected.posstart=posstart;
 selected.posend=posend;
 selected.negstart=negstart;
 selected.negend=negend;

 frameindex=mod(1,10)+1;
 for i=1:npart+1
     datatem{i}=zeros(10,2);
     datatem{i}(frameindex,1)=1;
     datatem{i}(frameindex,2)=0;
 end


%% initialize the variables
sbin = 8;       % bins for the Hog features
npart=3;         % number of parts
SV_v=cell(npart+1,8);
msg=cell(1,npart+1);
boundtotal=zeros(10,4);
part=cell(1,npart+1);
affinere=cell(1,npart+1);
pos=cell(1,npart+1);
neg=cell(1,npart+1);
motionvec=cell(1,npart+1);
meanval=cell(1,npart+1);
SVindex_v=cell(npart+1,npart+1);

px=(bbtotal(2)+bbtotal(4))/2; py=(bbtotal(1)+bbtotal(3))/2; sx{npart+1}=round(bbtotal(4)-bbtotal(2)); sy{npart+1}=round(bbtotal(3)-bbtotal(1)); theta=0; 

p= [px, py, sx{npart+1}, sy{npart+1}, theta];  
affinetotal=[p(1), p(2), p(3)/sz(1), p(5), p(4)/p(3), 0]';
affinere{npart+1}=affinetotal;
resultpre=cell(1,npart+1);
subS
for frameNum=1:subS.endFrame-subS.startFrame+1
       fprintf('processing_%d_frame\n',frameNum')
       img=imread([subS.s_frames{frameNum}]);
       img_ori=img;
       if size(img,3)==3
         img=rgb2gray(img);  % we obtain the gray image
       end
           if frameNum==1  
               %% still initialize the parameters
                   [imghei imgwid]=size(img(:,:,1));
                   opttotalx=zeros(imghei,imgwid,10); 
                   opttotaly=zeros(imghei,imgwid,10);
                   opttotalcon=10*ones(imghei,imgwid,10);
                   imgtotal=zeros(imghei,imgwid,10);
                   imgtotal(:,:,2)=im2double(img(:,:,1));
                   affinetotalre=[p(1), p(2), p(3)/sz(1), p(5), p(4)/p(3), 0]';
                   resultpre{npart+1}=affinetotalre;
                  param.est=affparam2mat(affinetotalre);
              %% Draw the bounding box
                   drawopt = drawtrackresult([], frameNum, img, [], param, [],sz);
              %% extrct Hog features
                  [patch,affine,sample]=densesample_rough(img,affinere{npart+1},sz);
                  [postotal,negtotal]=densesample_getsample_frameone(patch,affine,affinere{npart+1},sample);
                   [~,lengthtotal]=size(postotal);
             %% Normalize the features
                   postotal=postotal./(repmat(sqrt(sum(postotal.^2,2)),1,lengthtotal)+eps);
                   negtotal=negtotal./(repmat(sqrt(sum(negtotal.^2,2)),1,lengthtotal)+eps);
                   frameindex=mod(frameNum+10,10)+1;
                   for i=1:npart
                  %% obtain the affine parameter for the first frame                  
                     px=round((bb{i}(2)+bb{i}(4))/2); py=round((bb{i}(1)+bb{i}(3))/2); sx{i}=round(bb{i}(4)-bb{i}(2)); sy{i}=round(bb{i}(3)-bb{i}(1)); theta=0; 
                     p= [px, py, sx{i}, sy{i}, theta];  
                     affinere{i}=[p(1), p(2), p(3)/sz(1), p(5), p(4)/p(3), 0]';
                     resultpre{i}=affinere{i};
                     bbcenter{i}=round(0.5*([bb{i}(2)+bb{i}(4) bb{i}(1)+bb{i}(3)]));
                    [patch,affine,sample]=densesample_rough1(img_ori,affinere{i},sz,frameNum);
                    [pos{i},neg{i}]=densesample_getsample_frameone(patch,affine,affinere{i},sample);
                     [~,lengthtotal]=size(pos{i});
                  %% normalize the features 
                     pos{i}=pos{i}./(repmat(sqrt(sum(pos{i}.^2,2)),1,lengthtotal)+eps);  
                     neg{i}=neg{i}./(repmat(sqrt(sum(neg{i}.^2,2)),1,lengthtotal)+eps);
                     datahistory{i}(frameindex,:)=pos{i}(1,:);
                   end
                   length1=size(postotal,2);
                   length2=size(pos{1},2);
                    whistory=zeros(10,length1+3*length2+40);
                    wtotal=zeros(1,length1+3*length2+40);
                    pos{npart+1}=postotal; neg{npart+1}=negtotal;
                    bbcenter{npart+1}=round(0.5*([bbtotal(2)+bbtotal(4) bbtotal(1)+bbtotal(3)])); 
                                       for i=1:npart+1
                                             for j=i:npart+1
                                                disvec{i,j}=bbcenter{i}-bbcenter{j}; 
                                             end
                                       end
                %% construct the spatial tree
                      part{4}.child(1)=1; part{4}.child(2)=2; part{4}.child(3)=3; part{4}.parent=0;
                      part{1}.parent=4; part{2}.parent=4; part{3}.parent=4;  
                      part{1}.child=0; part{2}.child=0; part{3}.child=0; 
                      affinepre=[];
                      w=[];  
                      SV_v=cell(4,8);
                      SV_u=cell(1,npart+1);
                      SVindex_v=cell(4,8);
                      SVindex_u=cell(1,npart+1);
                      SVindex_u{npart+1}=0; SV_u{npart+1}=[];
                   %% consider the temporal connection
                       SV_v{1,5}=[]; SVindex_v{1,5}=0; SV_v{2,6}=[]; SVindex_v{2,6}=0; SV_v{3,7}=[]; SVindex_v{3,7}=0; SVindex_v{4,8}=0;
                    hiddenpart=[];            
            else  
                  imgtotal(:,:,mod(frameNum,10)+1)=im2double(img(:,:,1));
                  if frameNum==3
                      part{1}.child=5; part{2}.child=6; part{3}.child=7;  part{4}.child(4)=8;
                  end
                        if frameNum==182
                            a=1;
                        end
                  %% compute the optical flow between two successive frames
                           [px,py,uncertain,optmapx,optmapy,optconfidence]=calopt_flow(img,preimg,affinere,npart,sz);   
                          
                           disvec{1,5}=[px{1} py{1}]; disvec{2,6}=[px{2} py{2}]; disvec{3,7}=[px{3} py{3}]; disvec{4,8}=[px{4} py{4}];
                                opttotalx(:,:,mod(frameNum,10)+1)=optmapx;
                                opttotaly(:,:,mod(frameNum,10)+1)=optmapy;
                                opttotalcon(:,:,mod(frameNum,10)+1)=optconfidence;
                                
                             if frameNum==82
                                 a=1;
                             end
                           [affine,part,hiddenpart,w,SV_v,SVindex_v,SV_u,SVindex_u,affinere,postem,negtem,datahistory,whistory,maxscore,wtotal,selected,storepos,storeneg,datatem,msg,mask,disvec,isright,SampleNum]=dodetection(img_ori,mask,msg,datatem,storepos,storeneg,selected,wtotal,maxscore,whistory,datahistory,sx,sy,postem,negtem,uncertain,w,SV_v,SVindex_v,SV_u,SVindex_u,img,frameNum,postotal,negtotal,pos,neg,affinere,sz,npart,part,disvec,hiddenpart,affinepre,px,py);
                           for i=1:npart+1                               
                               resultpre{i}(:,frameNum)=affinere{i}; 
                               affinepre{i}=affine{i}(:,1:SampleNum(i));
                           end
                      for i=1:npart
                          for j=i:npart+1 
                              if isright(i)==0
                                 disvec{i,j}=0.8*disvec{i,j}+0.2*(affinere{i}(1:2)-affinere{j}(1:2))';
                              else
                                  disvec{i,j}=(affinere{i}(1:2)-affinere{j}(1:2))';
                              end
                          end
                      end 
                           
                           affinetotalre=affinere{npart+1};
                 
                           res(frameNum,:)=[affinetotalre(1)*1 affinetotalre(2)*1 affinetotalre(3)*1 0 affinetotalre(5) 0];
                          %% we convert the results to the format that is accepted by the benchmark
                             param.est=affparam2mat(res(frameNum,:));
                             res(frameNum,:)=param.est;
                             drawopt = drawtrackresult(drawopt, frameNum, imresize(img,1), [], param, [],sz);

                           param.est=affparam2mat(affinere{1});
                           res1(frameNum,:)=param.est;
%                            drawbox(sz, param.est, 'Color','r', 'LineWidth',2.5);
                           param.est=affparam2mat(affinere{2});
                           res2(frameNum,:)=param.est; 
 %                          drawbox(sz, param.est, 'Color','r', 'LineWidth',2.5);
                           param.est=affparam2mat(affinere{3});
                           res3(frameNum,:)=param.est;      
%                           drawbox(sz, param.est, 'Color','r', 'LineWidth',2.5);

                      part{5}.sel=part{1}.sel; part{6}.sel=part{2}.sel; part{7}.sel=part{3}.sel; part{8}.sel=part{4}.sel;
                      for i=1:npart+1
                          part{i}.msg=[];
                      end
           end
           boundtotal(mod(frameNum,10)+1,1)=floor(affinere{npart+1}(1)-sx{npart+1}/2);
           boundtotal(mod(frameNum,10)+1,2)=floor(affinere{npart+1}(1)+sx{npart+1}/2);
           boundtotal(mod(frameNum,10)+1,3)=floor(affinere{npart+1}(2)-sy{npart+1}/2);
           boundtotal(mod(frameNum,10)+1,4)=floor(affinere{npart+1}(2)+sy{npart+1}/2);
           preimg=img;
end
