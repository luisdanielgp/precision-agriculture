%% Test, pruebas del clasificador

%proporción de datos para la prueba

rootFolder = 'test';
testSet = imageDatastore(fullfile(rootFolder, categories), 'LabelSource', 'foldernames');
testSet.ReadFcn = @readFunctionTrain;

%extracción de 'features' (características) sel set de imágenes de prueba

testFeatures = activations(convnet, testSet, featureLayer);
predictedLabels = predict(classifier, testFeatures);

%accuracy

confMat = confusionmat(testSet.Labels, predictedLabels);
confMat = confMat./sum(confMat,2);
mean(diag(confMat))