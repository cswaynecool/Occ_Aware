function [pos,neg]=catfeature(parentnode,postem,negtem,child)
pos=[]; neg=[];
 for childi=1:length(child)
     if child(childi)>parentnode
         samplenum(childi)=size(postem{parentnode,child(childi)},2);
     else
         samplenum(childi)=size(postem{child(childi),parentnode},2);
     end
 end  
     maxsamplenum=max(samplenum);
     maxsamplenum=max(maxsamplenum,size(postem{parentnode,parentnode},1));
     [height,width]=size(postem{parentnode,parentnode});
     pos=[pos [postem{parentnode,parentnode};zeros(maxsamplenum-height,width)]];
     for childi=1:length(child)
              if parentnode<child(childi)
               [height,width]=size(postem{parentnode,child(childi)});
                   if maxsamplenum>height
                     pos=[pos [postem{parentnode,child(childi)};zeros(maxsamplenum-height,4)]];
                   else
                     pos=[pos [postem{parentnode,child(childi)}]];
                   end
              else
               [height,width]=size(postem{child(childi),parentnode});
                    if maxsamplenum>height
                     pos=[pos [postem{child(childi),parentnode};zeros(maxsamplenum-height,4)]];
                    else
                     pos=[pos [postem{child(childi),parentnode}]];
                    end
              end
     end
  %% we begin constructing negative samples
  for childi=1:length(child)
     if child(childi)>parentnode
         samplenum(childi)=size(negtem{parentnode,child(childi)},2);
     else
         samplenum(childi)=size(negtem{child(childi),parentnode},2);
     end
  end
     maxsamplenum=max(samplenum);
     maxsamplenum=max(maxsamplenum,size(negtem{parentnode,parentnode},1)); 
     [height,width]=size(negtem{parentnode,parentnode});
     if maxsamplenum>height
           neg=[neg [negtem{parentnode,parentnode};zeros(maxsamplenum-height,4)]];
     else
           neg=[neg [negtem{parentnode,parentnode}]];
     end
     for childi=1:length(child)
                if parentnode<child(childi)
                     
                     [height,width]=size(negtem{parentnode,child(childi)});
                     if maxsamplenum>height
                     neg=[neg [negtem{parentnode,child(childi)};zeros(maxsamplenum-height,4)]];
                     else
                      neg=[neg [negtem{parentnode,child(childi)}]];
                     end
                else
                     [height,width]=size(negtem{child(childi),parentnode});
                        if maxsamplenum>height
                        neg=[neg [negtem{child(childi),parentnode};zeros(maxsamplenum-height,4)]];
                        else
                         neg=[neg [negtem{child(childi),parentnode}]];
                        end
                end         
     end
     
     