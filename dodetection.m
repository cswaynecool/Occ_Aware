 function [affine,part,hiddenpart,w,SV_v,SVindex_v,SV_u,SVindex_u,affinere,postem,negtem,datahistory,whistory,maxscore,wtotal,selected,storepos,storeneg,datatem,msg,mask,disvec,isright,SampleNum]=dodetection(img_ori,mask,msg,datatem,storepos,storeneg,selected,wtotal,maxscore,whistory,datahistory,sx,sy,postem,negtem,uncertain,w,SV_v,SVindex_v,SV_u,SVindex_u,img,frameNum,postotal,negtotal,pos,neg,affinere,sz,npart,part,disvec,hiddenpart,affinepre,px,py)
                                                                                                           

 posstart=selected.posstart;
 posend=selected.posend;
 negstart=selected.negstart;
 negend=selected.negend;
   sizepo=size(postotal,1);
   hoglengthtotal=size(postotal,2);
   hoglength=size(pos{1},2);
sumhoglength(1)=hoglengthtotal;
posnow=cell(1,npart+1);
for i=1:npart+1
    hoglength(i)=size(pos{i}(1,:),2);  
    if i>1
        sumhoglength(i)=hoglength(i-1)+sumhoglength(i-1);   
    end
end
%% train the model when frameNum==2
        if frameNum==2  % we use SVM for training
              for i=1:npart    % train for each patch
                 length1=size(pos{i},1); length2=size(neg{i},1);
              
                  label_vector(1:length1)=1; label_vector(length1+1:length1+length2)=0;
                  train_data=cat(1,pos{i},neg{i}); 
                  alpha = svmtrain(label_vector', train_data, '-c 0.1 -t 0');
                  w(sumhoglength(i)+1:sumhoglength(i+1))=sum( repmat(alpha.sv_coef,1,size(pos{i},2)).*alpha.SVs);
                  SV_u{i}=alpha.SVs;  
                  SVindex_u{i}=alpha.nSV(1); 
                  label_vector=1;
              end
                 
                   length1=size(postotal,1); length2=size(negtotal,1);
                   label_vector1(1:length1)=1; label_vector1(length1+1:length1+length2)=0;
                   train_data=cat(1,postotal,negtotal); 
                   alpha = svmtrain(label_vector1', train_data, '-c 0.001 -t 0');
                   w(1:hoglengthtotal)=sum( repmat(alpha.sv_coef,1,size(pos{npart+1},2)).*alpha.SVs);
                   w(sumhoglength(npart+1)+1:sumhoglength(npart+1)+40)=0;
                   w=w';
        end
    [patch,affine{npart+1},sampletotal]=densesample_rough(img,affinere{npart+1},sz);
    record=patch;

    [~,hoglength]=size(sampletotal);  
    sampletotal=sampletotal./(repmat(sqrt(sum(sampletotal.^2,2)),1,hoglength)+eps); 
    
    for i=1:npart   % extract features for each fragment
          [~,affine{i},sample{i}]=densesample_rough1(img_ori,affinere{i},sz,frameNum);
          [~,hoglength]=size(sample{i});  
          sample{i}=sample{i}./(repmat(sqrt(sum(sample{i}.^2,2)),1,hoglength)+eps);           
    end
    sample{npart+1}=sampletotal;
    
    for i=1:npart+1
     SampleNum(i)=size(sample{i},1);
    end
      sample{npart+1}=sampletotal;
      turn=decideturn(part,npart);
      turn(npart+1)=1; % By default, the holistic target lies in the first layer
          if frameNum>2   
               for i=1:npart+1
                   affine{npart+i+1}=affinepre{i};
                   try
                   affinedo{npart+i+1}=affinepre{i}(:,1:end);
                   catch
                       a=1;
                   end
               end
          end
      
       for i=1:npart+1
           affinedo{i}=affine{i}(:,1:SampleNum(i));
           sampledo{i}=sample{i}(1:SampleNum(i),:);
       end
        sampletotaldo=sampletotal(1:SampleNum(npart+1),:);
        if frameNum==241
            a=1;
        end
      [part,score]=domessagepass(storeneg,mask,sumhoglength,uncertain,frameNum,turn,w,sampletotaldo,sampledo,part,npart,disvec,affinedo,SampleNum,hiddenpart);   % we perform max-sum message passing operation
      part=backtrace(part,turn); % we perform back trace operation
     
      frameindex=mod(frameNum+10,10)+1;
      for i=1:npart+1
          datahistory{i}(frameindex,:)=sample{i}(part{i}.sel,:);  %% the unary term for the inference of the occlusion state 
      end
      
       wtotal(frameNum,:)=w';
       whistory(frameindex,:)=w';
  
     %% we compute the temporal node, i.e., node from the previous frame
     hiddenpart=decidehiddenpart(uncertain,sample,npart,w,frameNum,score,hiddenpart,affinedo,affinepre,SampleNum,px,py);
  
         %% we reinitialize the fragments that driff away from the holistic target.
              [isright,affinere,SV_u,SVindex_u,w,hiddenpart,postem,posstart,posend]=tellright(posstart,posend,postem,frameNum,hiddenpart,w,part,affine,npart,SV_u,SVindex_u,sx,sy);
   %% we estimate the scale for the holistic target
              affinere{npart+1}=estimate_scale(affinere{npart+1},img,w(1:hoglengthtotal));
              isright(npart+1)=0; 
                   trainingindex=mod(frameNum,5)+1;
                   for i=1:4
                       for j=1:8
                       posstart(i,j,trainingindex)=size(postem{i,j},1)+1;
                       negstart(i,j,trainingindex)=size(negtem{i,j},1)+1;
                       end
                   end
                  
              for i=1:npart+1             
                      sel1=part{i}.sel; child=part{i}.child;
                     [postem,negtem,posnow{i},negnow{i}]=getsample(record,postem,negtem,uncertain,frameNum,sel1,turn,w,child,i,part,affine,sample,SampleNum,npart,disvec,1-isright(i));         
                      if frameNum<6
                        storepos{i}=[storepos{i};posnow{i}];
                        storeneg{i,frameindex}=[negnow{i}];
                         storeneg{i,frameindex}=[negnow{i}];
                      end
                       
              end
                for i=1:4
                       for j=1:8 
                          posend(i,j,trainingindex)=size(postem{i,j},1);
                          negend(i,j,trainingindex)=size(negtem{i,j},1);
                       end
                end
      %% we estimate the occlusion state
               [mask,datatem]=getmask(datahistory,datatem,storepos,storeneg,frameNum,npart);         
         
             %%
              if frameNum<7
      %% model update   
                [w,SV_v,SVindex_v,SV_u,SVindex_u]=updatew_svm(uncertain,postem,negtem,SV_v,SVindex_v,SV_u,SVindex_u,frameNum,w,disvec,part,turn,affine,SampleNum,sample,sampletotal,npart,sz);       
                postem=cell(4,8);
                negtem=cell(4,8);
              elseif mod(frameNum,5)==1
                      posnow=cell(4,8);  
                      negnow=cell(4,8);
                      for i=4:-1:0
                          trainingindex=mod(frameNum-i+5,5)+1; frameindex=mod(frameNum-i+10,10)+1;
                                    if mask{1}(frameindex)==2
                                        mask{5}(frameindex)=2;
                                        w(hoglength*(npart)+hoglengthtotal+1:hoglength*(npart)+hoglengthtotal+4)=0;
                                        SV_v{1,5}=[];
                                        SVindex_v{1,5}=0;
                                    else
                                        mask{5}(frameindex)=1;
                                    end
                                    if mask{2}(frameindex)==2
                                        mask{6}(frameindex)=2;
                                        w(hoglength*(npart)+hoglengthtotal+5:hoglength*(npart)+hoglengthtotal+8)=0;
                                        SV_v{2,6}=[];
                                        SVindex_v{2,6}=0;
                                    else
                                        mask{6}(frameindex)=1;
                                    end 
                                     if mask{3}(frameindex)==2
                                        mask{7}(frameindex)=2;  
                                        w(hoglength*(npart)+hoglengthtotal+9:hoglength*(npart)+hoglengthtotal+12)=0;
                                        SV_v{3,7}=[];
                                        SVindex_v{3,7}=0;
                                    else
                                        mask{7}(frameindex)=1;
                                    end
                                    if mask{4}(frameindex)==2
                                        mask{8}(frameindex)=2;
                                        w(end-3:end)=0;
                                        SV_v{4,8}=[];
                                        SVindex_v{4,8}=0;
                                    else
                                        mask{8}(frameindex)=1;
                                    end
                            
                     for rows=1:4
                        for columns=1:8
                               if mask{rows}(frameindex)==1&&mask{columns}(frameindex)==1
                                         num=posend(rows,columns,trainingindex)-posstart(rows,columns,trainingindex)+1;
                                         if num~=0&&posend(rows,columns,trainingindex)>0
                                         posnow{rows,columns}(end+1:end+num,:)=postem{rows,columns}(posstart(rows,columns,trainingindex):posend(rows,columns,trainingindex),:);   
                                         end
                                         num=negend(rows,columns,trainingindex)-negstart(rows,columns,trainingindex)+1;
                                         if num~=0&&negend(rows,columns,trainingindex)>0
                                         negnow{rows,columns}(end+1:end+num,:)=negtem{rows,columns}(negstart(rows,columns,trainingindex):negend(rows,columns,trainingindex),:);  
                                         end
                              end
                        end
                      end                
                   end

                   for i=1:npart+1
                     if ~isempty(posnow{i,i}) 
                         storepos{i}=[storepos{i};posnow{i,i}(1,:)];
                     else
                      storepos{i}=[storepos{i};postem{i,i}(1,:)];
                      end
                      storeneg{i,frameindex}=[negnow{i,i}];
                   end
                  [w,SV_v,SVindex_v,SV_u,SVindex_u]=updatew_svm(uncertain,posnow,negnow,SV_v,SVindex_v,SV_u,SVindex_u,frameNum,w,disvec,part,turn,affine,SampleNum,sample,sampletotal,npart,sz);
                        
                  postem=cell(4,8);
                  negtem=cell(4,8);
              end
              if frameNum==230
                  a=1;
              end
 selected.posstart=posstart;
 selected.posend=posend;
 selected.negstart=negstart;
 selected.negend=negend;
      
    
