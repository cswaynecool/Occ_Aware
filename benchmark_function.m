close all
clear
clc
warning off all;
addpath 'libsvm'
addpath('dat')
addpath('MEEM_code');
addpath('utils');
addpath('mex');
    
addpath(genpath('benchmark\'));
 seqs=configSeqs;

trackers=configTrackers;

shiftTypeSet = {'left','right','up','down','topLeft','topRight','bottomLeft','bottomRight','scale_8','scale_9','scale_11','scale_12'};

evalType='OPE'; %'OPE','SRE','TRE'

numSeq=length(seqs);
numTrk=length(trackers);

finalPath = ['benchmark\results\' evalType '\'];

if ~exist(finalPath,'dir')
    mkdir(finalPath);
end

tmpRes_path = ['benchmark/tmp/' evalType '/'];
bSaveImage=0;

if ~exist(tmpRes_path,'dir')
    mkdir(tmpRes_path);
end

pathAnno = 'benchmark/anno/';

for idxSeq=1:length(seqs)
    s = seqs{idxSeq};
        
    s.len = s.endFrame - s.startFrame + 1;
    s.s_frames = cell(s.len,1);
    nz	= strcat('%0',num2str(s.nz),'d'); %number of zeros in the name of image
    for i=1:s.len
        image_no = s.startFrame + (i-1);
        id = sprintf(nz,image_no);
        s.s_frames{i} = strcat(s.path,id,'.',s.ext);
    end
    
    img = imread(s.s_frames{1});
    [imgH,imgW,ch]=size(img);
    
    rect_anno = dlmread([pathAnno s.name '.txt']);
    numSeg = 20;
    
    [subSeqs, subAnno]=splitSeqTRE(s,numSeg,rect_anno);
    
    switch evalType
        case 'SRE'
            subS = subSeqs{1};
            subA = subAnno{1};
            subSeqs=[];
            subAnno=[];
            r=subS.init_rect;
            
            for i=1:length(shiftTypeSet)
                subSeqs{i} = subS;
                shiftType = shiftTypeSet{i};
                subSeqs{i}.init_rect=shiftInitBB(subS.init_rect,shiftType,imgH,imgW);
                subSeqs{i}.shiftType = shiftType;
                
                subAnno{i} = subA;
            end

        case 'OPE'
            subS = subSeqs{1};
            subSeqs=[];
            subSeqs{1} = subS;
            
            subA = subAnno{1};
            subAnno=[];
            subAnno{1} = subA;
        otherwise
    end

            
    for idxTrk=1:1
       t.name='occ_aware';
       t.namePaper='occ_aware';

      %% tell if the results exist
        if exist([finalPath s.name '_' 'occ_aware' '.mat'])
            load([finalPath s.name '_' 'occ_aware' '.mat']);
            continue;
        end

        switch t.name
            case {'VTD','VTS'}
                continue;
        end

        results = [];
        for idx=1:length(subSeqs)
            disp([num2str(idxTrk) '_' t.name ', ' num2str(idxSeq) '_' s.name ': ' num2str(idx) '/' num2str(length(subSeqs))])       

            rp = [tmpRes_path s.name '_' t.name '_' num2str(idx) '/'];  %file for storage
            if bSaveImage&~exist(rp,'dir')
                mkdir(rp);
            end
            
            subS = subSeqs{idx};
            
            subS.name = [subS.name '_' num2str(idx)];
            
              t1=clock;
              [mm mm1 mm2 mm3]=run_my(subS);
              t2=etime(clock,t1);
              res.fps=s.len/t2;
              res.res=mm;
              res.res1=mm1;
              res.res2=mm2;
              res.res3=mm3;
                  res.len = subS.len;
            res.annoBegin = subS.annoBegin;
            res.type='ivtAff';
            res.tmplsize=[64 64];
            res.startFrame = subS.startFrame;
            results{idx} = res;
        end     
        end
        save([finalPath s.name '_' t.name '.mat'], 'results');
    end


figure
t=clock;
t=uint8(t(2:end));
disp([num2str(t(1)) '/' num2str(t(2)) ' ' num2str(t(3)) ':' num2str(t(4)) ':' num2str(t(5))]);

