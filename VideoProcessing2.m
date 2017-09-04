%% %% Let's try with a video 


clear all;
close all;
clc;   




%% Let's continue the tests

% fileFolder = fullfile(matlabroot,'toolbox','images','imdata');
% dirOutput = dir(fullfile(fileFolder,'AT3_1m4_*.tif'));
% fileNames = {dirOutput.name}';
% numFrames = numel(fileNames);

[fileNames, path] = uigetfile ('*.*','MultiSelect','on');
I = strcat(path,fileNames);
numFrames  = size(char(fileNames),1);
I2 = I.';
I1 = imread(I2{1,1});
sequence = zeros([size(I1) numFrames],'like',I1);
sequence(:,:,:,1) = I1;
im_size_x = size(I1,1);
im_size_y = size(I1,2);


for n = 1:numFrames
    
   tempNames =  strsplit(fileNames{1,n},'.');
   fileNames{1,n} = tempNames{1,1};

end
for p = 2:numFrames
    I3 = imread(I2{p,1});
    I4 = imresize(I3,[im_size_x im_size_y]);
    sequence(:,:,:,p) = I4; 
end

colors = cell(numFrames,numFrames);
Fnames = char(fileNames);
Fname = fileNames.';
prompt1 = 'Which Organs? ';
prompt2 = 'Number of organes : ';


for idx = 1:numFrames
    imshow(sequence(:,:,:,idx),[]);
    nb = input(prompt2);
    for idx2 = 1:nb
        str = input(prompt1,'s');
        colors{idx,idx2} = cat(1,cellstr(str),impixel);     
    end 
    
end

idxs = size(colors);


%% Let's go for the difficult part
ouin = [];
% tmpcolors = cell(1,100); %numFrames);
z =1;
for i1 = 1:idxs(1)
    for i2 = 1:idxs(2)
        if(~isempty(colors{i1,i2}) )
            ouin = [ouin,colors{i1,i2}{1,1},' '];
            tmpcolors{1, z} = colors{i1,i2}{2,1};
            z = z +1;
        end
    end
end

bla1 = tmpcolors(~cellfun('isempty',tmpcolors));
c = strsplit(ouin);
c = c(1,1:end-1);
d = c;
bla1;

for m=1:size(c,2)
    for o =1:size(c,2)
        if(strcmp(c(m),c(o))&& m~=o && m<o)
            d{1,o}= NaN;
            bla1{1,m} = [bla1{1,m}; bla1{1,o}];
            bla1{1,o} = [NaN,NaN,NaN];
                     
        end
    end
end

bla2 = cellfun(@(x) x(isfinite(x)), bla1, 'UniformOutput',false);
tmpcell = zeros(round(size(bla2,1)/3),3); 
tmpmatrix = [];
bla4 = bla2(~cellfun('isempty',bla2));
r=1;
bla3 = cell(1,size(bla4,2));
for q =1:size(bla4,2)
    

    tmpmatrix = [tmpmatrix ; bla4{1,q}]
    for s=1:length(tmpmatrix)
        if(r <= length(tmpmatrix))
            tmpcell(s,1) = tmpmatrix(r,1)
            tmpcell(s,2) = tmpmatrix(r+1,1)
            tmpcell(s,3) = tmpmatrix(r+2,1)
            bla3{1,q} = [bla3{1,q} ; tmpcell(s,:)]
            r = r +3;
        end
    end
    r=1;
    tmpmatrix = [];
    
    
end


% bla = bla2(~cellfun('isempty',bla2));
e = cellfun(@(x) x(isfinite(x)), d , 'UniformOutput',false);
f =  e(~cellfun('isempty',e));


red = cell(size(bla3));
green = cell(size(bla3));
blue = cell(size(bla3));

for j = 1:size(bla3,2)
    v = bla3{1,j};
    r = v(:,1);
    g = v(:,2);
    b = v(:,3);
   
    red{1,j} = r ;
    green{1,j} = g;
    blue{1,j} = b;
    
end
red_mean = [];
green_mean = [];
blue_mean = [];
for k = 1:size(bla3,2)
    red_mean = [red_mean,round(mean(red{1,k}))];
    green_mean = [green_mean,round(mean(green{1,k}))];
    blue_mean = [blue_mean,round(mean(blue{1,k}))];
end


% 
fid = fopen('test3.txt', 'wt');
for l=1:size(bla3,2)
    fprintf(fid,'%s %f %f %f\r\n',f{1,l}, red_mean(l), green_mean(l), blue_mean(l));
end
    fclose(fid);


