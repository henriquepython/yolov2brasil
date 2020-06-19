%UNEF
%ENGENHARIA ELÉTRICA
%INTELIGÊNCIA ARTIFICIAL
%% limpa dados
clear; close all; imtool close all; clc;
%% carrega arquivo gTruth
    
load (fullfile('gTruth3.mat')) 

%% tabela das imagens
trainingData = objectDetectorTrainingData(gTruth,'SamplingFactor',1)
%% exibe uma amostra da tabela 
trainingData(1:4,:)
%% design e treino
%% define tamanho de entrada
inputSize = [224 224 3];
%% numero de classes
numClasses = width(trainingData)-1;
%% executar o codigo anchorboxes da pasta
%TEM QUE BAIXAR O TOOLBOX DEEP LEARNING
%% 
resizedAnchors=floor(anchorBoxes.*[224 224]./[540 960]);

%% rede pretreinada
baseNetwork=resnet50;

%% corta camada da resnet50 
featureLayer='activation_40_relu';
%% 

lgraph=yolov2Layers([224 224 3],numClasses,...
resizedAnchors,baseNetwork,featureLayer);
%% abrir deepnetworkdesign
deepNetworkDesigner
%% opções de treino
 options = trainingOptions('adam', ...
        'InitialLearnRate',0.0001, ...
        'Verbose',true,'MiniBatchSize',8,'MaxEpochs',3,...
        'Shuffle','every-epoch','VerboseFrequency',1, ...
        'LearnRateSchedule','piecewise','LearnRateDropFactor',0.2,'LearnRateDropPeriod',2);
    

%% primeiro treino (criar detector)
[detectorYoloV2, info] = trainYOLOv2ObjectDetector(trainingData,lgraph,options);
%% accuracy de treino
figure
plot(info.TrainingLoss)
grid on
xlabel('Number of Iterations')
ylabel('Training Loss for Each Iteration')
%% opções de re-treino
 options = trainingOptions('adam', ...
        'InitialLearnRate',0.000000000256, ...
        'Verbose',true,'MiniBatchSize',8,'MaxEpochs',3,...
        'Shuffle','every-epoch','VerboseFrequency',1, ...
        'LearnRateSchedule','piecewise','LearnRateDropFactor',0.2,'LearnRateDropPeriod',2);
%% re-treinar detector(Após primeiro treino)
[detectorYoloV2, info] = trainYOLOv2ObjectDetector(trainingData,detectorYoloV2,options);
%% accuracy de re-treino
figure
plot(info.TrainingLoss)
grid on
xlabel('Number of Iterations')
ylabel('Training Loss for Each Iteration')
%% 
       
    results = table('Size',[height(trainingData) 3],...
    'VariableTypes',{'cell','cell','cell'},...
    'VariableNames',{'Boxes','Scores', 'Labels'});
%% aprimora performace
for k=1:height(trainingData)
I=imread(trainingData.imageFilename{k});
[bboxes,scores,labels]=detect(detectorYoloV2,I,'Threshold',0.2);
results.Boxes{k}=bboxes;
results.Scores{k}=scores;
results.Labels{k}=labels;
end

%% limite de detecção
threshold =0.2;
%% 
[ap, recall, precision] = evaluateDetectionPrecision(results, trainingData(:,2:end),threshold);

%% 
   [am,fppi,missRate] = evaluateDetectionMissRate(results, trainingData(:,2:end),threshold);
%% grafico de precisão 
   subplot(1,2,1);
plot(recall{1,1},precision{1,1},'g-','LineWidth',2, "DisplayName",'COM_MASCARA');
hold on;
plot(recall{2,1},precision{2,1},'b-','LineWidth',2, "DisplayName",'SEM_M');
hold on;


xlabel('Recall');
ylabel('Precision');
title(sprintf('Average Precision = %.2f\n', ap))
legend('Location', 'best');
legend('boxoff')
grid on

subplot(1,2,2);
loglog(fppi{1,1}, missRate{1,1},'-g','LineWidth',2, "DisplayName",'COM_MASCARA');
hold on;
loglog(fppi{2,1}, missRate{2,1},'-b','LineWidth',2, "DisplayName",'SEM_M');
hold on;


xlabel('False Positives Per Image');
ylabel('Log Average Miss Rate');
title(sprintf('Log Average Miss Rate = %.2f\n', am))
legend('Location', 'best');
legend('boxoff')
grid on


%% 
depVideoPlayer = vision.DeployableVideoPlayer;
%% executa classificação com imagens
 
for i = 1:height(trainingData)
    
    % Read the image
    I = imread(trainingData.imageFilename{i});
    
    % Run the detector.
    [bboxes,scores,labels] = detect(detectorYoloV2,I);
    
    %
    if ~isempty(bboxes)
        I = insertObjectAnnotation(I,'Rectangle',bboxes,cellstr(labels));
        depVideoPlayer(I);
        pause(0.1);

    end    
    
    % Collect the results in the results table
    results.Boxes{i} = floor(bboxes);
    results.Scores{i} = scores;
    results.Labels{i} = labels;
    
end

%% teste com video
videoFile = 'video novo.mp4';
videoFreader = vision.VideoFileReader(videoFile,'VideoOutputDataType','uint8');
depVideoPlayer = vision.DeployableVideoPlayer('Size','Custom','CustomSize',[640 480]);
cont = ~isDone(videoFreader);
while cont
    I = step(videoFreader);
    in = imresize(I,[224,224]);
    out = yolov2_detection3(in);
    depVideoPlayer(out);
    cont = ~isDone(videoFreader) && isOpen(depVideoPlayer); % Exit the loop if the video player figure window is closed
end
%% 
[imds] = objectDetectorTrainingData('C:\Users\user\Documents\MATLAB\IMAGE LABELER FULL\dataset','SamplingFactor',1)
%% testar network
       
    results = table('Size',[height(trainingData) 3],...
    'VariableTypes',{'cell','cell','cell'},...
    'VariableNames',{'Boxes','Scores', 'Labels'});
%% aprimora performace
for k=1:height(test)
I=imread(test.imageFilename{k});
[bboxes,scores,labels]=detect(detectorYoloV2,I,'Threshold',0.2);
results.Boxes{k}=bboxes;
results.Scores{k}=scores;
results.Labels{k}=labels;
end