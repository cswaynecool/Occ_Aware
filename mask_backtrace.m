function [mask,datatem]=mask_backtrace(postotal,negtotal,datatem,datahistory,frameNum)
%% we perform the backtrace for the occlusion state

num=min(frameNum,10);

msg=zeros(10,2);   
    for i=num-1:-1:0  
      frameindexpre=mod(frameNum-i+9,10)+1;  
      frameindex=mod(frameNum-i+10,10)+1;
       if i==num-1 
               msg(frameindex,1)=datatem(frameindex,1); msg(frameindex,2)=datatem(frameindex,2); 
       elseif i==0
                Y=datahistory(frameindex,:)';
                N=size(postotal',2);  
                X=postotal';
                k=repmat(Y,1,N);
                ff=( sum( (k-X).^2,1));
                k1=min(ff);
                N=size(negtotal',2);  
                X=negtotal';
                k=repmat(Y,1,N);
                ff=( sum( (k-X).^2,1));
                k2=min(ff);
              datatem(frameindex,1)=k2/(k1+k2);
              datatem(frameindex,2)=k1/(k1+k2);
              tem=1/(1+norm(datahistory(frameindex,:)-datahistory(frameindexpre,:)));
              [msg(frameindex,1),sel(frameindex,1)]=max( [datatem(frameindex,1)+tem+msg(frameindexpre,1),datatem(frameindex,1)+msg(frameindexpre,2)]);
              [msg(frameindex,2),sel(frameindex,2)]=max( [datatem(frameindex,2)+msg(frameindexpre,1), datatem(frameindex,2)+tem+msg(frameindexpre,2) ]);
       else
                      tem=1/(1+norm(datahistory(frameindex,:)-datahistory(frameindexpre,:)));
                      [msg(frameindex,1),sel(frameindex,1)]=max( [datatem(frameindex,1)+tem+msg(frameindexpre,1),datatem(frameindex,1)+msg(frameindexpre,2)]);
                      [msg(frameindex,2),sel(frameindex,2)]=max( [datatem(frameindex,2)+msg(frameindexpre,1), datatem(frameindex,2)+tem+msg(frameindexpre,2) ]);
       end
    end
  
   mask=go_back(frameNum,sel,msg,num);
    