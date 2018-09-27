% Croping program
num = 0;
for k = 1:33
  jpgFilename = sprintf('%d.jpeg', k);
  path = '/Users/ld/Documents/precision_ag/flores';
  fullFileName = fullfile(path, jpgFilename);
  % Setup parameters for segmentation

    % RGB values for segmentation
    limit = [197 56 25];
    distanceLimit = 74;
  
  if exist(fullFileName, 'file')
    
    img = imread(fullFileName);
    %img_reduc = impyramid(img, 'reduce');
    img_reduc = img;
    src = imgaussfilt(img_reduc,2);
    [fil, col, channel] = size(src);
    srcBin = zeros(fil,col);
    
    for i = 1:1:fil
        for j = 1:1:col

            pixel = double([src(i,j,1) src(i,j,2) src(i,j,3)]);
            distance = norm(limit - pixel);

            if (distance < distanceLimit)
                srcBin(i,j) = 1;
            end
        end
    end
    
    se =  strel('square',3);
    seDilate =  strel('square',2);

    erodeSrcBin = imerode(srcBin, se);
    srcOpen = imopen(srcBin,se);
    srcOpen = imopen(srcOpen,se);
    srcClose = imclose(srcOpen,se);
    srcDilate = imdilate(srcOpen,seDilate);
    srcDilate = imdilate(srcDilate,seDilate);
    %figure()
    %imshow = (srcDilate);

    img_3 = uint8(srcDilate).*img_reduc;
    
    [L,Ne]=bwlabel(srcDilate);

    prop= regionprops(L);

    hold on
    for n=1:size(prop,1)

        k = n;
        boundingBox = prop(n).BoundingBox;
        rectangle('Position',[boundingBox(1),boundingBox(2),boundingBox(3),boundingBox(4)],... 
        'EdgeColor','g','LineWidth',2)

        samples = imcrop(img_3, [boundingBox(1),boundingBox(2),boundingBox(3),boundingBox(4)]);
        imwrite(samples, strcat(['/Users/ld/Documents/precision_ag/crops_flores/sample_' ,num2str(k), '.png']))

    end
    
    
    
  else
    warningMessage = sprintf('Warning: image file does not exist:\n%s', fullFileName);
    uiwait(warndlg(warningMessage));
  end
  fprintf('Imagen %i\n', num);
  num = num + 1;
end