function [Bitrate,MSE,PSNR] = DistortionOutputs(OriginalImage,ReconstructedImage,ImageHeight,ImageWidth,ImageDim,Bits,Bytestream)
    Bitrate = length(Bytestream)*Bits / (ImageWidth * ImageHeight);
    MSE = sum((OriginalImage(:) - ReconstructedImage(:)).^2)/(ImageHeight*ImageWidth*ImageDim);
    PSNR = 10*log10((((2.^Bits)-1)^2)/MSE);
end