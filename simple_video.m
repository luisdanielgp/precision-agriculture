

% RGB values for segmentation
limit = [197 56 25];
distanceLimit = 74;

obj=VideoReader('/Users/ld/Documents/precision_ag/DJI_0002.MP4');
nFrames=obj.NumberOfFrames;
for k=1:nFrames
    %img=read(obj,k);
    img = impyramid(read(obj,k), 'reduce');
    
    [fil, col, channel] = size(img);
    imgBin = zeros(fil,col);
    for i = 1:1:fil
        for j = 1:1:col

            pixel = double([img(i,j,1) img(i,j,2) img(i,j,3)]);
            distance = norm(limit - pixel);

            if (distance < distanceLimit)
                imgBin(i,j) = 1;
            end
        end
    end
    se =  strel('square',3);
    seDilate =  strel('square',2);

    erodeSrcBin = imerode(imgBin, se);
    imgOpen = imopen(imgBin,se);
    imgOpen = imopen(imgOpen,se);
    imgClose = imclose(imgOpen,se);
    imgDilate = imdilate(imgOpen,seDilate);
    imgDilate = imdilate(imgDilate,seDilate);
    
    [L,Ne]=bwlabel(imgDilate);

    prop= regionprops(L);
    
    hold on
    for n=1:size(prop,1)

        k = n;
        boundingBox = prop(n).BoundingBox;
        rectangle('Position',[boundingBox(1),boundingBox(2),boundingBox(3),boundingBox(4)],... 
        'EdgeColor','g','LineWidth',2)

    end
    hold off
    
    figure(1),imshow(img,[]);
end