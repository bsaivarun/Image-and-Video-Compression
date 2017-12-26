function [Reconstructed_Y Reconstructed_Cb Reconstructed_Cr] = IntraDecode_Integer(Reconstructed_Data,Image,Scaling_Factor,OptimizationScheme,EOB)

[ImageHeight ImageWidth ImageDim] = size(Image);
Block = 4;
flag = 0;
RLDec_Full = ZeroRunDec4x4(Reconstructed_Data,EOB);
RLDec_Y = RLDec_Full(1,1:size(RLDec_Full,2)/3);
RLDec_Cb = RLDec_Full(1,size(RLDec_Full,2)/3+1:2*size(RLDec_Full,2)/3);
RLDec_Cr = RLDec_Full(1,2*size(RLDec_Full,2)/3+1:end);

for i = 0:Block:ImageHeight-Block
    for j = 0:Block:ImageWidth-Block
        %% RunLengthDecoding --> DeZigZagScan --> DeQuantization --> InverseDCT
        flag = flag+1;
        
        [DeZigZag_Y DeZigZag_Cb DeZigZag_Cr] = deZigZag4x4(RLDec_Y((flag-1)*16+1:flag*16),RLDec_Cb((flag-1)*16+1:flag*16),RLDec_Cr((flag-1)*16+1:flag*16));
        [DeQI_Y DeQI_Cb DeQI_Cr] = DeQuant4x4(DeZigZag_Y,DeZigZag_Cb,DeZigZag_Cr,Scaling_Factor);
        if ( OptimizationScheme==1)
            [IIT_Y IIT_Cb IIT_Cr] = IDCT4x4(DeQI_Y,DeQI_Cb,DeQI_Cr);
        elseif ( OptimizationScheme==2)
            [IIT_Y IIT_Cb IIT_Cr] = IIT4x4(DeQI_Y,DeQI_Cb,DeQI_Cr);
        end
        
        %% Image Reconstruction
        Reconstructed_Y(i+1:i+4,j+1:j+4) = IIT_Y;
        Reconstructed_Cb(i+1:i+4,j+1:j+4) = IIT_Cb;
        Reconstructed_Cr(i+1:i+4,j+1:j+4) = IIT_Cr;
    end
end

end