close all
clear all
clc
%% Setup parameters for segmentation

% RGB values for segmentation
limit = [197 56 25];
%limit = [98, 29, 17];
distanceLimit = 74; % distancia euclidiana
%% Get image src

img = imread('Users/ld/Desktop/flores_naranjas.jpeg');
img_reduc = impyramid(img, 'reduce');
src = imgaussfilt(img_reduc,2);
figure()
imshow(img); title('Imagen original');
figure()
subplot(1,2,1); imshow(img_reduc); title('Imagen reducida');
subplot(1,2,2); imshow(src); title('Imagen reducida con filtro de Gauss');
[fil, col, channel] = size(src);
srcBin = zeros(fil,col);
%% Segmentation

for i = 1:1:fil
    for j = 1:1:col
        
        pixel = double([src(i,j,1) src(i,j,2) src(i,j,3)]);
        distance = norm(limit - pixel);
        
        if (distance < distanceLimit)
            srcBin(i,j) = 1;
        end
    end
end
%% Morphological operations for blob reconstruction

% Structure elements
se =  strel('square',3); %Estructura cuadrada de 3x3 para erosionar
seDilate =  strel('square',2); %Estructura cuadrada de 2x2 para dilatar

erodeSrcBin = imerode(srcBin, se);
srcOpen = imopen(srcBin,se);
srcOpen = imopen(srcOpen,se);
srcClose = imclose(srcOpen,se);
srcDilate = imdilate(srcOpen,seDilate);
srcDilate = imdilate(srcDilate,seDilate);

figure()
imshow(srcDilate);
title('Segmentación en binario');

img_3 = uint8(srcDilate).*img_reduc;

%Extract mask from original image
increased_srcDilate = imresize(srcDilate,2);
mask = repmat(increased_srcDilate,[1,1,3]);
srcOut = img.* uint8(mask);
figure()
subplot(1,2,1); imshow(img); title("Imagen original");
subplot(1,2,2); imshow(srcOut); title("Máscara extraída de la imagen original");
%%  regionprops

[L,Ne]=bwlabel(srcDilate);

prop= regionprops(L);
figure()
imshow(img_reduc);
title('Segmentación en rectángulos');

hold on
mean_flores = [0, 0, 0];
mr = 0;
mg = 0;
mb = 0;
for n=1:size(prop,1)
    
    k = n;
    boundingBox = prop(n).BoundingBox;
    rectangle('Position',[boundingBox(1),boundingBox(2),boundingBox(3),boundingBox(4)],... 
    'EdgeColor','g','LineWidth',2)
    
    samples = imcrop(img_3, [boundingBox(1),boundingBox(2),boundingBox(3),boundingBox(4)]);
    %imwrite(samples, strcat(['/Users/ld/Documents/precision_ag/sample_' ,num2str(k), '.png']))
    mean_sample = mean(mean(samples));
    mr = mr+mean_sample(1);
    mg = mg+mean_sample(2);
    mb = mb+mean_sample(3);
end
mr = mr/n;
mg = mg/n;
mb = mb/n;
hold off

figure()
imshow(img_reduc);
title('Perímetros por segmentación');

hold on
B = bwboundaries(srcDilate);
for k = 1:length(B)
    boundary = B{k};
    plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
end
hold off

total_pixels = sum(sum(srcDilate));
fprintf('*** El área total en pixeles de las flores es de: %d px ***\n',total_pixels);

mean_pixels = [mr, mg, mb];
fprintf('*** La media de RGB es: %0.2f, %0.2f, %0.2f ***\n', mean_pixels(1), mean_pixels(2), mean_pixels(3));
