function [Reconstructed_Y Reconstructed_Cb Reconstructed_Cr] = IntraDecode_AC_DC(Reconstructed_Data,Reconstructed_Data_PCDM,Image,Scaling_Factor)
    
    [ImageHeight ImageWidth ImageDim] = size(Image);
    Block = 8;
    flag = 0;
    RLDec_Full = ZeroRunDec_AC_DC(Reconstructed_Data,Reconstructed_Data_PCDM);
    RLDec_Y = RLDec_Full(1,1:size(RLDec_Full,2)/3);
    RLDec_Cb = RLDec_Full(1,size(RLDec_Full,2)/3+1:2*size(RLDec_Full,2)/3);
    RLDec_Cr = RLDec_Full(1,2*size(RLDec_Full,2)/3+1:end);
    
    for i = 0:Block:ImageHeight-Block
        for j = 0:Block:ImageWidth-Block
        %% RunLengthDecoding --> DeZigZagScan --> DeQuantization --> InverseDCT
        flag = flag+1;
        
        [DeZigZag_Y DeZigZag_Cb DeZigZag_Cr] = DeZigZag8x8(RLDec_Y((flag-1)*64+1:flag*64),RLDec_Cb((flag-1)*64+1:flag*64),RLDec_Cr((flag-1)*64+1:flag*64));
        [DeQI_Y DeQI_Cb DeQI_Cr] = DeQuant8x8(DeZigZag_Y,DeZigZag_Cb,DeZigZag_Cr,Scaling_Factor);
        [IDCT_Y IDCT_Cb IDCT_Cr] = IDCT8x8(DeQI_Y,DeQI_Cb,DeQI_Cr);
        %% Image Reconstruction
        Reconstructed_Y(i+1:i+8,j+1:j+8) = IDCT_Y;
        Reconstructed_Cb(i+1:i+8,j+1:j+8) = IDCT_Cb;
        Reconstructed_Cr(i+1:i+8,j+1:j+8) = IDCT_Cr;
        end
    end

end