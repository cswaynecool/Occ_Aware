function drawopt = drawtrackresult(drawopt, fno, frame, tmpl, param, pts,sz)
frame=im2double(frame);
if (isempty(drawopt))       %%绘图属性
   
  figure('position',[0 0 320 240]); clf;                               
  set(gcf,'DoubleBuffer','on','MenuBar','none');
  colormap('gray');

  drawopt.curaxis = [];
  drawopt.curaxis.frm  = axes('position', [0.00 0 1.00 1.0]);
end

%%绘制全图
curaxis = drawopt.curaxis;
axes(curaxis.frm);      
imagesc(frame, [0,1]);
hold on;     

%%绘制图标跟踪框
% sz = [32 32];  
drawbox(sz, param.est, 'Color','r', 'LineWidth',2.5);

%%显示目前跟踪的是第几帧
text(5, 18, num2str(fno), 'Color','y', 'FontWeight','bold', 'FontSize',18);

hold off;
drawnow;        %%  更新视图

