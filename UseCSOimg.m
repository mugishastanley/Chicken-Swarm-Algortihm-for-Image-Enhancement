%In this code, the two controlling parameters are lamda and gamma,
%increasing lamda increases contrast whereas increasing gamma,
%slowly(usually between 1000-100000) retains the overbrightness of white 
%pixels.
%in original paper, the scholar hasn't used lamda in cdf function,
%hence thereby, restricting himself to increase lamda
%line 53 and 54 contains lamda and gamma respectively


% clc
clear all
for p=1:255
   for q=1:256
       if p==q
        D(p,q) = -1;
       elseif q==p+1
           D(p,q) = 1;
       else
           D(p,q) = 0;
       end
   end
  
end
    
clc

i = imread('ImgOrig.png');
r = i(:,:,1);
g = i(:,:,2);
b = i(:,:,3);
figure,imshow(i)
title('Original Image')

%for n=1:256
 %   histogram(1,n) = 0;
%for l = 1:size_of_image(1)
 %   for b = 1:size_of_image(2)
  %      if grays(l,b)==n
   %     histogram(1,n) = histogram(1,n)+1;
    %    end
    %end
%end
%end
%x = 1:1:256;
%figure, plot(x,histogram)
[freqr xr] =  imhist(r);
[freqg xg] =  imhist(g);
[freqb xb] =  imhist(b);
size_of_image = size(r);
number_of_pixels = size_of_image(1)*size_of_image(2);

lamda = 4;%variable to determine the amount of contrast
%gamma = 50000 ;
gamma = 50000 ;


% smoothing_factor = inv(((1+lamda).*eye(256) + gamma.*transpose(D)*D));
% for n = 0:1:255                     
%     nfreqr(n+1,1) = (freqr(n+1,1) + lamda*n);
%     nfreqg(n+1,1) = (freqg(n+1,1) + lamda*n);
%     nfreqb(n+1,1) = (freqb(n+1,1) + lamda*n);
% end
% 
% freqr = smoothing_factor*nfreqr;
% freqg = smoothing_factor*nfreqg;
% freqb = smoothing_factor*nfreqb;

hir = freqr;                %for R
[freqr,fminr] = CSOimg(500, 100, 256 , 10, 0.15, 0.7, 0.5,hir,lamda,gamma,D,xr);
freqr = transpose(freqr);

hig = freqg;            %for G
[freqg,fming] = CSOimg(500, 100, 256 , 10, 0.15, 0.7, 0.5,hig,lamda,gamma,D,xg);
freqg = transpose(freqg);

hib = freqb;               %for B
[freqb,fminb] = CSOimg(500, 100, 256 , 10, 0.15, 0.7, 0.5,hib,lamda,gamma,D,xb);
freqb = transpose(freqb);
for n = 0:1:255                     %probablity Density Function
    p(n+1,1) = freqr(n+1,1)/number_of_pixels;
end

cr = zeros(256,1); %cumulative density function 
cg = zeros(256,1); 
cb = zeros(256,1); 

cr(1,1) = freqr(1,1);
cg(1,1) = freqg(1,1); 
cb(1,1) = freqb(1,1);

for n = 1:1:255
    cr(n+1,1) = cr(n,1) + freqr(n+1,1);
    cg(n+1,1) = cg(n,1) + freqg(n+1,1);
    cb(n+1,1) = cb(n,1) + freqb(n+1,1);
end

for n = 0:1:255
    cr(n+1,1) = cr(n+1,1)/number_of_pixels;
    cg(n+1,1) = cg(n+1,1)/number_of_pixels;
    cb(n+1,1) = cb(n+1,1)/number_of_pixels;
end

cdfr = (lamda+1)*(255.*cr + 0.5);
cdfg = (lamda+1)*(255.*cg + 0.5);
cdfb = (lamda+1)*(255.*cb + 0.5);
cdfr = round(cdfr);
cdfg = round(cdfg);
cdfb = round(cdfb);

%main Image
main_image = uint8(zeros(size_of_image(1),size_of_image(2),3));
c = 1;
    for l = 1:size_of_image(1)
        for w = 1:size_of_image(2)
             main_image(l,w,c) = cdfr(r(l,w)+1,1);
             main_image(l,w,c+1) = cdfg(g(l,w)+1,1);
             main_image(l,w,c+2) = cdfb(b(l,w)+1,1);
        end
    end


figure, imshow(main_image),title('Histogram Modified')
figure, hist(main_image(:,:,1),xr);
hold on
hist(main_image(:,:,2),xg);
hist(main_image(:,:,3),xb);

entropy_of_original_image = entropy(i)
entropy_of_image = entropy(main_image)

[peaksnr, snr] = psnr(main, i);
  
fprintf('\n The Peak-SNR value is %0.4f', peaksnr);

mean_Optimized = mean2(main_image);
var_optimzed = std2(main_image);
D = abs(uint8(main_image) - uint8(i)).^2;
mse = sum(D(:))/numel(main_image);
psnr = 10*log10(255*255/mse);

%mae = meanAbsoluteError(main_image,i)
%E = eme(main_image,size_of_image(1),5)
