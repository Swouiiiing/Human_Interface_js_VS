%% %% Let's try with a video 


clear all;
close all;
clc;   




%% Selection of the files

% Let the user select the frames he need
[fileNames, path] = uigetfile ('*.*','MultiSelect','on');
I = strcat(path,fileNames);
numFrames  = size(char(fileNames),1);
% Transpose I
I2 = I.';
% I1 = imread(I);
I1 = imread(I2{1,1});
% Depending of the path, you might change the previous lines,
% comment/uncomment

% sequence will containe all the frames it is 4 dimension because we need
% to store the 2 dimensions information of the frams
sequence = zeros([size(I1) numFrames],'like',I1);
sequence(:,:,:,1) = I1;
% Get the size of the frame
im_size_x = size(I1,1);
im_size_y = size(I1,2);

% Resize the frames, sequence is filled
for p = 2:numFrames
    I3 = imread(I2{p,1});
    I4 = imresize(I3,[im_size_x im_size_y]);
    sequence(:,:,:,p) = I4; 
end

%% Display

%Initialize the varaiable which will contain the colors after user input
colors = cell(numFrames,numFrames);
% Messages which will be displayed with the frame
prompt1 = 'Which Organs? ';
prompt2 = 'Number of organs : ';

% Display the frames and ask for the number of organs and which organs.
% While we havn't reach the number of organs the user has input for this
% frame
for idx = 1:numFrames
    imshow(sequence(:,:,:,idx),[]);
    nb = input(prompt2);
    for idx2 = 1:nb
        str = input(prompt1,'s');
%         with impixel we get the rgb values of the pixel the user clicked on 
        colors{idx,idx2} = cat(1,cellstr(str),impixel);     
    end 
    
end

idxs = size(colors);


%% Delete empty cells of the cell array
% Color is a n by n cell array with n the number of frames. 
% But for each frames we don't have the same number of organes,
% so we have a lot of empty cells, we will delete them to be able to
% manipulate the data
names = [];
z =1;
for i1 = 1:idxs(1)
    for i2 = 1:idxs(2)
%         if the value is not empty we add the name of the organ to an
%         array and add the data to a cell array
        if(~isempty(colors{i1,i2}) )
            names = [names,colors{i1,i2}{1,1},' '];
            tmpcolors{1, z} = colors{i1,i2}{2,1};
            z = z +1;
        end
    end
end

% This delete empty values
bla1 = tmpcolors(~cellfun('isempty',tmpcolors));
% we split the names and delet the last blank space because names is a
% char array with a blank space at the end of each names
c = strsplit(names);
c = c(1,1:end-1);
d = c;

% This will compare the names of the organs. If we have the same organ on
% different frames, we concatenate the data in the first reference to the
% organe and delete the others. Ex if we have artery bone skin artery and
% as data [255,0,0 ; 200,10,0] [255,255,255] [200, 100,0] [255,100,100],
% after this loop we will have :
% artery bone skin NaN
% [255,0,0 ; 200,10,0 ; 255,100,100] [255,255,255] [200,100,0] [NaN,NaN,NaN]
for m=1:size(c,2)
    for o =1:size(c,2)
        if(strcmp(c(m),c(o))&& m~=o && m<o)
            d{1,o}= NaN;
            bla1{1,m} = [bla1{1,m}; bla1{1,o}];
            bla1{1,o} = [NaN,NaN,NaN];
                     
        end
    end
end
% We change Nan by empty elements and delet these empty elements however
% this function concanete the rgb values of each cell in one n by 1 array 
% As a result we have in bla 2 all the values in one column for each organ,
% the problem is it is sorted by value witch mean first all the red values,
% then all the green and the all blue, so the following loop will fill in
% bla3 in order to have for each organ : r g b  (click 1)
%                                         r g b  (click 2) etc
bla2 = cellfun(@(x) x(isfinite(x)), bla1, 'UniformOutput',false);
bla4 = bla2(~cellfun('isempty',bla2));
tmpcell = zeros(round(size(bla2,1)/3),3); 
tmpmatrix = [];

r=1;
bla3 = cell(1,size(bla4,2));

for q =1:size(bla4,2)
    tmpmatrix = [tmpmatrix ; bla4{1,q}];
    for s=1:length(tmpmatrix)
        if(r <= length(tmpmatrix)/3)
            tmpcell(s,1) = tmpmatrix(r,1);
            tmpcell(s,2) = tmpmatrix(r+length(tmpmatrix)/3,1);
            tmpcell(s,3) = tmpmatrix(r+2*length(tmpmatrix)/3,1);
            bla3{1,q} = [bla3{1,q} ; tmpcell(s,:)];
            r = r +1;
        end
    end
    r=1;
    tmpmatrix = [];
    
    
end


% Sort the names by alphabetical order
e = cellfun(@(x) x(isfinite(x)), d , 'UniformOutput',false);
f =  e(~cellfun('isempty',e));

% initialize values for separating colors
red = cell(size(bla3));
green = cell(size(bla3));
blue = cell(size(bla3));
% fill in red, green and blue. Each column of red is all the red values of 
% an organ the user has input with the clicks

for j = 1:size(bla3,2)
    v = bla3{1,j};
    r = v(:,1);
    g = v(:,2);
    b = v(:,3);
   
    red{1,j} = r ;
    green{1,j} = g;
    blue{1,j} = b;
    
end
% initialize the final variables
red_mean = [];
green_mean = [];
blue_mean = [];
% we do the mean, for each organ, of the red, green and blue components
for k = 1:size(bla3,2)
    red_mean = [red_mean,round(mean(red{1,k}))];
    green_mean = [green_mean,round(mean(green{1,k}))];
    blue_mean = [blue_mean,round(mean(blue{1,k}))];
end


% then we finaly write on the text file the name of the organe which is in
% f and its r g b values.
% We can change the name of the file, but don't forget to change it in the
% application
fid = fopen('test3.txt', 'wt');
for l=1:size(bla3,2)
    fprintf(fid,'%s %f %f %f\r\n',f{1,l}, red_mean(l), green_mean(l), blue_mean(l));
end
    fclose(fid);


