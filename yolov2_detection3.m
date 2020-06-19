function outImg = yolov2_detection3 (in) 


persistent yolov2Obj; 

if isempty (yolov2Obj) 
    yolov2Obj = coder.loadDeepLearningNetwork ('detector2.mat'); 
end 

% pass in input 
[bboxes, scores, labels] = yolov2Obj.detect (in, 'Threshold', 0.2); 
outImg = in;

% convert categorical labels to cell array of character vectors for MATLAB 
% execution 
if coder.target('MATLAB') 
    labels = cellstr(labels); 
end 

if ~ (isempty (bboxes) && isempty (labels)) 
% Annotate detections in the image. 
    outImg = insertObjectAnnotation(in,'rectangle',bboxes,labels); 
end