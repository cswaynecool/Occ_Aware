function hiddenpart=decidehiddenpart(uncertain,sample,npart,w,frameNum,score,hiddenpartpre,affine,affinepre,SampleNum,px,py)
 %% we comput the information for the temporal node
 hiddenpart=cell(1,npart);
 hoglength=size(sample{1},2);
 hoglengthtotal=size(sample{npart+1},2);
 map(1)=1; map(2)=2; map(3)=3; map(4)=10;
           if frameNum==2
              for i=1:npart+1
                 hiddenpart{i}.msg=score{i};
              end
           else
                for node=1:npart+1
                    index=hoglengthtotal+(npart)*hoglength+(map(node)-1)*4+1;
                    for nodei=1:SampleNum(node) 
                          dx=affine{node}(1,nodei)-affinepre{node}(1,:)-px{node};
                          dy=affine{node}(2,nodei)-affinepre{node}(2,:)-py{node};     
                          dx=dx'; dy=dy';
                            if uncertain(node)==0
                                 disvec1=0.001*[dx dx.^2 dy dy.^2];
                            else 
                                 disvec1=0.000*[dx dx.^2 dy dy.^2];
                            end
                          hiddenpart{node}.msg(nodei,1)=0.7*max( score{node}(nodei)+(disvec1*w(index:index+3)+sum(hiddenpartpre{node}.msg,2))); 
                    end
                end
           end