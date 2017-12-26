clear all
close all
clc

OriginalImage = (imread('data/Images/lena_gray.tif'));
OriginalImage_Y = double((OriginalImage));
Image = OriginalImage;
[ImageHeight ImageWidth ImageDim] = size(OriginalImage);
% n = input('How many levels of Decomposition required?\n');
n = 3;

%% Analysis Filters Low-Pass and High-Pass

F0 = [0.0267,-0.0169,-0.0782,0.2668,0.6029,0.2668,-0.0782,-0.0169,0.0267];
F1 = [0.0912,-0.0575,-0.5912,1.1150,-0.5912,-0.0575,0.0912];
Length_LowPass = length(F0);
Length_HighPass = length(F1);

%% Synthesis Filters Low-Pass and High-Pass
G0 = F1 .* [-1 1 -1 1 -1 1 -1];
G1 = F0 .* [1 -1 1 -1 1 -1 1 -1 1];

%% Decomposition of Image DWT
Image = OriginalImage_Y;tic
Wavelet = WaveletDecomposition(Image,F0,F1,n);

%% Deadzone Quantization
Wavelet = round(Wavelet);
% Mean = mean(Wavelet(:))*ones(512);
% Wavelet = round(Wavelet - Mean);

for i = 1 : numel(Wavelet)
    if(mod(Wavelet(i),2) ~= 0)
        Wavelet(i) = Wavelet(i)+1;
    end
    if(((Wavelet(i) < 6) && (Wavelet(i) > -6)))
        Wavelet(i) = 0;
    end
end
tic
%% Splitting into Sign and Bit-Planes
[Output Refinement RefinFlagTotal MaxBits Bitstream Bitstream_Sig] = EZWEncode(Wavelet,n);toc
[OutputRows OutputCols] = cellfun(@size,Output);
[RefinementRows RefinementCols] = cellfun(@size,Refinement);
TotalBits = (sum(OutputCols)*2)+sum(RefinementCols);
BitRate = TotalBits/(ImageHeight*ImageWidth);
TotalBitstream = [];
for i = 1:MaxBits
    TotalBitstream =  [TotalBitstream Bitstream{i} 555];
    if i<=7
        TotalBitstream =  [TotalBitstream Bitstream_Sig{i+1} 777];
    end
end

%% EZW Decoding
tic
Wavelet_Decoded = EZWDecode(Output,Refinement,RefinFlagTotal,OriginalImage,n,MaxBits);
toc
%% Reconstruction of Image iDWT
Wavelet_Reconstructed = WaveletReconstruction(Wavelet_Decoded,n,G0,G1);

%% Required Outputs
[BR,MSE,PSNR] = DistortionOutputs(Image,Wavelet_Reconstructed,ImageHeight,ImageWidth,ImageDim,8,0);
fprintf('\n\tBitRate = %f bpp\n',BitRate);
fprintf('\n\tPSNR = %f dB\n',PSNR);


