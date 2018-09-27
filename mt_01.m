%% Clasificador

%loading neural net
convnet = alexnet;
%layers
convnet.Layers % Take a look at the layers

%---------------

categories = {'flor','noflor'};

rootFolder = 'flores';
imds = imageDatastore(fullfile(rootFolder, categories), ...
    'LabelSource', 'foldernames');

featureLayer = 'fc7';
trainingFeatures = activations(convnet, trainingSet, featureLayer);

%Entrenamiento del clasificador SVM

classifier = fitcnb(trainingFeatures, trainingSet.Labels);