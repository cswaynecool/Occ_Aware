function [pos,neg,posnow,negnow]=getsample(record,pos,neg,uncertain,frameNum,sel1,turn,w,child,parentnode,part,affine,sample,SampleNum,npart,disvec,istrue)
%% we obtain the positive and negative samples
map=[0 7 8 4 1 0 0 0; 7 0 9 5 0 2 0 0;8 9 0 6 0 0 3 0; 4 5 6 0 0 0 0 10; 1 0 0 0 0 0 0 0;0 2 0 0 0 0 0 0;0 0 3 0 0 0 0 0; 0 0 0 10 0 0 0 0];
optcoe=0.002;
strcoe=0.001;
negindex=1;
         if part{parentnode}.child~=0
           part=decide_pos_in_training_process(parentnode,child,part);
         end

indexnum=0;


for i=1:6
    for j=1:16
        indexnum=indexnum+1;
        radius=12+(i-1)*8;
        theta=j*2*pi/16;
        xcoe(indexnum)=affine{parentnode}(1,sel1)+radius*cos(theta);
        ycoe(indexnum)=affine{parentnode}(2,sel1)+radius*sin(theta);      
    end
end

   for i=1:96
       dis=(affine{parentnode}(1,:)-xcoe(i)).^2+(affine{parentnode}(2,:)-ycoe(i)).^2;
       [~,part{parentnode}.selnegnow(negindex)]=min(dis);
       negindex=negindex+1;
   end
   
   negnow=get_neg_now(sel1,parentnode,affine,SampleNum,sample);


   negindex=96;
     for i=1:negindex-1
         hogindex=part{parentnode}.selnegnow(i);
         hoglength=size(sample{parentnode}(1,:),2);

         neg{parentnode,parentnode}(end+1,1:hoglength)=sample{parentnode}(hogindex,:);

              if max(child)>0
                  for childi=1:length(child) 
                     childnode=child(childi);
                     index1=part{parentnode}.selnegnow(i); index2=part{childnode}.sel;
                     if parentnode<childnode
                        dx=affine{parentnode}(1,index1)-affine{childnode}(1,index2)-disvec{parentnode,childnode}(1);
                        dy=affine{parentnode}(2,index1)-affine{childnode}(2,index2)-disvec{parentnode,childnode}(2);
                        dx=dx'; dy=dy';
                        disvec1=[dx min(dx.^2,100) dy min(dy.^2,100)]; 
                          if  4<child(childi)&&child(childi)<9&&uncertain(parentnode)==0
                                    neg{parentnode,child(childi)}(end+1,1:4)=optcoe*disvec1;
                                    
                             elseif 4<child(childi)&&child(childi)<9&&uncertain(parentnode)==1
                                    neg{parentnode,child(childi)}(end+1,1:4)=0*disvec1;
                                  
                             else   neg{parentnode,child(childi)}(end+1,1:4)=strcoe*disvec1;
                                   
                          end
                     else 
                        dx=affine{childnode}(1,index2)-affine{parentnode}(1,index1)-disvec{childnode,parentnode}(1);
                        dy=affine{childnode}(2,index2)-affine{parentnode}(2,index1)-disvec{childnode,parentnode}(2);
                        dx=dx'; dy=dy';
                        disvec1=[dx min(dx.^2,100) dy min(dy.^2,100)];  
                        
                          if  4<child(childi)&&child(childi)<9&&uncertain(parentnode)==0
                                    neg{child(childi),parentnode}(end+1,1:4)=optcoe*disvec1;
                                    
                             elseif 4<child(childi)&&child(childi)<9&&uncertain(parentnode)==1
                                    neg{child(childi),parentnode}(end+1,1:4)=0*disvec1;
                                    
                             else   neg{child(childi),parentnode}(end+1,1:4)=strcoe*disvec1;
                                   
                          end
                     end
                                    
                   end
              end
     end
     
    sampleindex=sel1;
     if frameNum<11
      negindex1=floor(negindex/8);
     else
     negindex1=5;
         if parentnode<4
             negindex1=5;
         end
     end
     hoglength=size(sample{parentnode}(1,:),2);
        pos{parentnode,parentnode}(end+1:end+negindex1-1,1:hoglength)=repmat(sample{parentnode}(sampleindex,:),negindex1-1,1);
    posnow=sample{parentnode}(sampleindex,:);
    if max(child)>0
          for childi=1:length(child)
             childnode=child(childi);
             index1=sel1; index2=part{childnode}.sel;
             if parentnode<childnode
                     dx=affine{parentnode}(1,index1)-affine{childnode}(1,index2)-disvec{parentnode,childnode}(1);
                     dy=affine{parentnode}(2,index1)-affine{childnode}(2,index2)-disvec{parentnode,childnode}(2);
                      dx=dx'; dy=dy';
                     disvec1=[dx dx^2 dy dy^2]; 
                     if dx^2>50||dy^2>50
                         setzero=1;
                     else
                         setzero=0;
                     end
                     if  4<child(childi)&&child(childi)<9&&uncertain(parentnode)==0
                               if setzero==1
                                   pos{parentnode,child(childi)}(end+1:end+negindex1-1,1:4)=zeros(negindex1-1,4);
                                   neg{parentnode,child(childi)}(end-negindex+2:end,1:4)=zeros(negindex-1,4); 
                               else
                                pos{parentnode,child(childi)}(end+1:end+negindex1-1,1:4)=repmat(optcoe*disvec1,negindex1-1,1);
                               end
                     elseif 4<child(childi)&&child(childi)<9&&uncertain(parentnode)==1
                                pos{parentnode,child(childi)}(end+1:end+negindex1-1,1:4)=repmat(0*disvec1,negindex1-1,1);
                     else
                            if setzero==1
                             pos{parentnode,child(childi)}(end+1:end+negindex1-1,1:4)=zeros(negindex1-1,4);   
                             neg{parentnode,child(childi)}(end-negindex+2:end,1:4)=zeros(negindex-1,4);  
                            else   
                            pos{parentnode,child(childi)}(end+1:end+negindex1-1,1:4)=repmat(strcoe*disvec1,negindex1-1,1);
                            end
                     end    
                     
             else 
                     dx=affine{childnode}(1,index2)-affine{parentnode}(1,index1)-disvec{childnode,parentnode}(1);
                     dy=affine{childnode}(2,index2)-affine{parentnode}(2,index1)-disvec{childnode,parentnode}(2);
                      dx=dx'; dy=dy';
                     disvec1=[dx dx.^2 dy dy.^2]; 
                     if dx^2>50||dy^2>50
                         setzero=1;
                     else
                         setzero=0;
                     end
                     if  4<child(childi)&&child(childi)<9&&uncertain(parentnode)==0
                                 if setzero==1
                                 pos{child(childi),parentnode}(end+1:end+negindex1-1,1:4)=zeros(negindex1-1,4);
                                 neg{child(childi),parentnode}(end-negindex+2:end,1:4)=zeros(negindex-1,4);
                                 else
                                 pos{child(childi),parentnode}(end+1:end+negindex1-1,1:4)=repmat(optcoe*disvec1,negindex1-1,1);
                                 end
                     elseif 4<child(childi)&&child(childi)<9&&uncertain(parentnode)==1
                                pos{child(childi),parentnode}(end+1:end+negindex1-1,1:4)=repmat(0*disvec1,negindex1-1,1);
                     else   
                              if setzero==1
                              pos{child(childi),parentnode}(end+1:end+negindex1-1,1:4)=zeros(negindex1-1,4);
                              neg{child(childi),parentnode}(end-negindex+2:end,1:4)=zeros(negindex-1,4);
                              else
                              pos{child(childi),parentnode}(end+1:end+negindex1-1,1:4)=repmat(strcoe*disvec1,negindex1-1,1);
                              end
                     end    
             end
                             
          end
    end
 