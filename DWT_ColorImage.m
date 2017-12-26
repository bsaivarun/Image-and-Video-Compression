clear all
% close all
% clc

OriginalImage = (imread('data/Images/lena.tif'));
OriginalImage = double((OriginalImage));
Image = OriginalImage;
[ImageHeight ImageWidth ImageDim] = size(OriginalImage);
[OriginalImage_Y OriginalImage_Cb OriginalImage_Cr] = ictRGB2YCbCr(OriginalImage(:,:,1),OriginalImage(:,:,2),OriginalImage(:,:,3));
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
for k =1:ImageDim
    if (k==1)
        Image = OriginalImage_Y;
    elseif (k==2)
        Image = OriginalImage_Cb;
    elseif (k==3)
        Image = OriginalImage_Cr;
    end
    tic
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

    %% Splitting into Sign and Bit-Planes
    [Output Refinement RefinFlagTotal MaxBits Bitstream Bitstream_Sig] = EZWEncode(Wavelet,n);
toc
    [OutputRows OutputCols] = cellfun(@size,Output);
    [RefinementRows RefinementCols] = cellfun(@size,Refinement);
    TotalBits = (sum(OutputCols)*2)+sum(RefinementCols);
    BitRate = TotalBits/(ImageHeight*ImageWidth);

    %% EZW Decoding
tic
    Wavelet_Decoded = EZWDecode(Output,Refinement,RefinFlagTotal,OriginalImage,n,MaxBits);

    %% Reconstruction of Image iDWT
    Wavelet_Reconstructed = WaveletReconstruction(Wavelet_Decoded,n,G0,G1);toc
    if (k==1)
        Wavelet_Reconstructed_Y = Wavelet_Reconstructed;
        Wavelet_Original_Y = Wavelet;
        BitRate_Y = BitRate;
        Output_Y = Output;
        Refinement_Y = Refinement;
    elseif (k==2)
        Wavelet_Reconstructed_Cb = Wavelet_Reconstructed;
        Wavelet_Original_Cb = Wavelet;
        BitRate_Cb = BitRate;
        Output_Y = Output;
        Refinement_Y = Refinement;
    elseif (k==3)
        Wavelet_Reconstructed_Cr = Wavelet_Reconstructed;
        Wavelet_Original_Cr = Wavelet;
        BitRate_Cr = BitRate;
        Output_Y = Output;
        Refinement_Y = Refinement;
    end
end
%% Required Outputs
[ReconstructedImage(:,:,1) ReconstructedImage(:,:,2) ReconstructedImage(:,:,3)] = ictYCbCr2RGB(Wavelet_Reconstructed_Y,Wavelet_Reconstructed_Cb,Wavelet_Reconstructed_Cr);

[BR,MSE,PSNR] = DistortionOutputs(OriginalImage,ReconstructedImage,ImageHeight,ImageWidth,ImageDim,8,0);
BitRate = BitRate_Y+BitRate_Cb+BitRate_Cr;
fprintf('\n\tBitRate = %f bpp\n',BitRate);
fprintf('\n\tPSNR = %f \n',PSNR);


