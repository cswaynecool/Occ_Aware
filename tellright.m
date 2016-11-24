function [isright,affinere,SV_u,SVindex_u,w,hiddenpart,postem,posstart,posend]=tellright(posstart,posend,postem,frameNum,hiddenpart,w,part,affine,npart,SV_u,SVindex_u,sx,sy)
map=[0 7 8 4 1 0 0; 7 0 9 5 0 2 0;8 9 0 6 0 0 3; 4 5 6 0 0 0 0; 1 0 0 0 0 0 0;0 2 0 0 0 0 0;0 0 3 0 0 0 0];
             hoglength=144;
             isright=zeros(1,npart);
             for i=1:npart+1
                  affinere{i}=affine{i}(:,part{i}.sel);
             end

             height=sy{npart+1};
             width=sx{npart+1};
             minxtotal=affinere{npart+1}(1)-width/2; maxxtotal=affinere{npart+1}(1)+width/2; minytotal=affinere{npart+1}(2)-height/2; maxytotal=affinere{npart+1}(2)+height/2;
             affineshou{1}(1)=affinere{npart+1}(1); affineshou{2}(1)=affinere{npart+1}(1);affineshou{3}(1)=affinere{npart+1}(1);
             affineshou{1}(2)=affinere{npart+1}(2)-height/3; affineshou{2}(2)=affinere{npart+1}(2);affineshou{3}(2)=affinere{npart+1}(2)+height/3;  
            for i=1:npart
                   minx=affinere{i}(1)-width/2; maxx=affinere{i}(1)+width/2; miny=affinere{i}(2)-height/6; maxy=affinere{i}(2)+height/6;
                   minx=max(minx,minxtotal); maxx=min(maxx,maxxtotal); miny=max(miny,minytotal); maxy=min(maxy,maxytotal);
                   overlap=max(maxx-minx,0)*max(maxy-miny,0)/sx{1}/sy{1};
                    if overlap<0.2
                     isright(i)=1;
                     affinere{i}(1)=affineshou{i}(1);
                     affinere{i}(2)=affineshou{i}(2);
                   if frameNum>3
                      hiddenpart{i}.msg=0*hiddenpart{i}.msg;
                   end
                    for j=1:7
                        postem{i,j}=[];
                        posstart(i,j,:)=0;
                        posend(i,j,:)=0;
                    end
                    for j=1:4
                        pos{j,i}=[];
                        posstart(j,i,:)=0;
                        posend(j,i,:)=0;
                    end 
                     SV_u{i}=[]; SVindex_u{i}=0; 
                     w(hoglength+(i-1)*hoglength+1:hoglength*(i+1))=0;
                    end               
            end
            
