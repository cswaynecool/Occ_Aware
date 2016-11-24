function mask=go_back(frameNum,sel,msg,num)
    frameindex=mod(frameNum+10,10)+1;
    [~,sel1]=max(msg(frameindex,:)); 
    mask(frameindex)=sel1;
for i=1:num-1
    frameindexpre=mod(frameNum-i+11,10)+1;
    frameindex=mod(frameNum-i+10,10)+1;
    mask(frameindex)=sel(frameindexpre,mask(frameindexpre));
end
    
    