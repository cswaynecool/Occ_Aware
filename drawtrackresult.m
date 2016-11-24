function drawopt = drawtrackresult(drawopt, fno, frame, tmpl, param, pts,sz)
frame=im2double(frame);
if (isempty(drawopt))       %%��ͼ����
   
  figure('position',[0 0 320 240]); clf;                               
  set(gcf,'DoubleBuffer','on','MenuBar','none');
  colormap('gray');

  drawopt.curaxis = [];
  drawopt.curaxis.frm  = axes('position', [0.00 0 1.00 1.0]);
end

%%����ȫͼ
curaxis = drawopt.curaxis;
axes(curaxis.frm);      
imagesc(frame, [0,1]);
hold on;     

%%����ͼ����ٿ�
% sz = [32 32];  
drawbox(sz, param.est, 'Color','r', 'LineWidth',2.5);

%%��ʾĿǰ���ٵ��ǵڼ�֡
text(5, 18, num2str(fno), 'Color','y', 'FontWeight','bold', 'FontSize',18);

hold off;
drawnow;        %%  ������ͼ

