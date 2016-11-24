function [patch affinerough sample]=densesample_rough1(img,affinere,sz,frame_id)

global config;
height=affinere(5)*affinere(3)*sz(1);
width=affinere(3)*sz(1);
selected_rect=[floor(affinere(1)-width/2) floor(affinere(2)-height/2) width height];
trackwin_max_dimension = 64;
template_max_numel = 144;
frame_min_width = 320;
frame_sz = size(img);
if max(selected_rect(3:4)) <= trackwin_max_dimension ||...
        frame_sz(2) <= frame_min_width
    config.image_scale = 1;
else
    min_scale = frame_min_width/frame_sz(2);
    config.image_scale = max(trackwin_max_dimension/max(selected_rect(3:4)),min_scale);    
end

wh_rescale = selected_rect(3:4)*config.image_scale;
win_area = prod(wh_rescale);
config.ratio = (sqrt(template_max_numel/win_area));
config.hist_nbin = 32;
config.padding = 40; % for object out of border
config.search_roi = 2;
config.use_iif = 1;
config.use_raw_feat = false;
if size(img,3)==1
    config.use_color=0;
else
    config.use_color=1;
end
if config.use_color
    thr_n = 5; 
else
    thr_n = 9;
end
config.thr = (1/thr_n:1/thr_n:1-1/thr_n)*255;
config.fd = numel(config.thr);
template_sz = round(wh_rescale*config.ratio); 
config.template_sz = template_sz([2 1]);
svm_tracker.output=selected_rect;
svm_tracker.output = selected_rect*config.image_scale;
        svm_tracker.output(1:2) = svm_tracker.output(1:2) + config.padding;
        svm_tracker.output_exp = svm_tracker.output;
[I_scale]= getFrame2Compute(img);
     if frame_id == 1
        sampler.roi = rsz_rt(svm_tracker.output,size(I_scale),5*config.search_roi,false);
    else%if svm_tracker.confidence > config.svm_thresh
        sampler.roi = rsz_rt(svm_tracker.output,size(I_scale),1*config.search_roi,true);
     end
 I_crop = I_scale(round(sampler.roi(2):sampler.roi(4)),round(sampler.roi(1):sampler.roi(3)),:);
 
 [BC F] = getFeatureRep(I_crop,config.hist_nbin);
 I_vf=BC;
 feature_map = imresize(I_vf,config.ratio,'nearest');
 ratio_x = size(I_vf,2)/size(feature_map,2);
ratio_y = size(I_vf,1)/size(feature_map,1);
template_sz = round(wh_rescale*config.ratio); 
config.template_sz = template_sz([2 1]);
sampler.template_size=config.template_sz;
patterns = im2colstep(feature_map,[sampler.template_size(1:2), size(I_vf,3)],[1, 1, size(I_vf,3)]);
x_sz = size(feature_map,2)-sampler.template_size(2)+1;
y_sz = size(feature_map,1)-sampler.template_size(1)+1;
[X Y] = meshgrid(1:x_sz,1:y_sz);
temp = repmat(svm_tracker.output,[numel(X),1]);
temp(:,1) = (X(:)-1)*ratio_x + sampler.roi(1);
temp(:,2) = (Y(:)-1)*ratio_y + sampler.roi(2);
init_rect=temp/config.image_scale;
nn=size(init_rect,1);
p=[init_rect(:,1)+init_rect(:,3)/2-config.padding, init_rect(:,2)+init_rect(:,4)/2-config.padding, init_rect(:,3), init_rect(:,4), zeros(nn,1)];
affine=[p(:,1), p(:,2), p(:,3)/sz(1), p(:,5), p(:,4)./p(:,3), zeros(nn,1)];
affinerough=affine';
sample=patterns';
patch=1;










