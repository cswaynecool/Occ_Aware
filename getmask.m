function [mask,datatem]=getmask(datahistory,datatem,storepos,storeneg,frameNum,npart)
frameindex=mod(frameNum+10,10)+1;
         for i=1:npart+1 
             negtotal=[];
             for index1=1:10    
                negtotal=[storeneg{i,index1};negtotal];
             end
                postotal=storepos{i};  
                if i==4&&frameNum>12
                    a=1;
                end
                [mask{i},datatem{i}]=mask_backtrace(postotal,negtotal,datatem{i},datahistory{i},frameNum);
                
         end
frameindex=mod(frameNum+10,10)+1;


