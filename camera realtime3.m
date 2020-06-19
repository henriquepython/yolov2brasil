
camera = webcam(1);

%% 

depVideoPlayer = vision.DeployableVideoPlayer;
%% 

while true
    I = camera.snapshot;
    in = imresize(I,[480,640]);
    out = yolov2_detection3(in);
    depVideoPlayer(out);
    % Exit the loop if the video player figure window is closed
end