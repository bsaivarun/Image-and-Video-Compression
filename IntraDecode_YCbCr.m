function Decoded_Ref_Frame = IntraDecode_YCbCr(zeroRun,Motion_Vector,Ref_Frame,Scaling_Factor)

    [FrameHeight FrameWidth FrameDim] = size(Ref_Frame);
    Ref_Frame_Y = Ref_Frame(:,:,1);
    Ref_Frame_Cb = Ref_Frame(:,:,2);
    Ref_Frame_Cr = Ref_Frame(:,:,3);
    Block = 8;
    flag = 0;
    zeroRunDec = ZeroRunDec_2(zeroRun);
    RLDec_Y = zeroRunDec(1,1:size(zeroRunDec,2)/3);
    RLDec_Cb = zeroRunDec(1,size(zeroRunDec,2)/3+1:2*size(zeroRunDec,2)/3);
    RLDec_Cr = zeroRunDec(1,2*size(zeroRunDec,2)/3+1:end);
    for i = 0:Block:FrameHeight-Block+1
        for j = 0:Block:FrameWidth-Block+1
        %% RunLengthDecoding --> DeZigZagScan --> DeQuantization --> InverseDCT
        flag = flag+1;
        
        [DeZigZag_Y DeZigZag_Cb DeZigZag_Cr] = DeZigZag8x8(RLDec_Y((flag-1)*64+1:flag*64),RLDec_Cb((flag-1)*64+1:flag*64),RLDec_Cr((flag-1)*64+1:flag*64));
        [DeQI_Y DeQI_Cb DeQI_Cr] = DeQuant8x8(DeZigZag_Y,DeZigZag_Cb,DeZigZag_Cr,Scaling_Factor);
        [IDCT_Y IDCT_Cb IDCT_Cr] = IDCT8x8(DeQI_Y,DeQI_Cb,DeQI_Cr);
        %% Image Reconstruction
        
        Error_Ref_Frame_Y(i+1:i+8,j+1:j+8) = IDCT_Y;
        Error_Ref_Frame_Cb(i+1:i+8,j+1:j+8) = IDCT_Cb;
        Error_Ref_Frame_Cr(i+1:i+8,j+1:j+8) = IDCT_Cr;
        
        Corrected_i = i+Motion_Vector(flag,1);
        Corrected_j = j+Motion_Vector(flag,2);

        Decoded_Ref_Frame_Y(i+1:i+8,j+1:j+8) = Error_Ref_Frame_Y(i+1:i+8,j+1:j+8) + Ref_Frame_Y(Corrected_i+1:Corrected_i+8,Corrected_j+1:Corrected_j+8);
        Decoded_Ref_Frame_Cb(i+1:i+8,j+1:j+8) = Error_Ref_Frame_Cb(i+1:i+8,j+1:j+8) + Ref_Frame_Cb(Corrected_i+1:Corrected_i+8,Corrected_j+1:Corrected_j+8);
        Decoded_Ref_Frame_Cr(i+1:i+8,j+1:j+8) = Error_Ref_Frame_Cr(i+1:i+8,j+1:j+8) + Ref_Frame_Cr(Corrected_i+1:Corrected_i+8,Corrected_j+1:Corrected_j+8);
      
        end
    end
    Decoded_Ref_Frame(:,:,1) = Decoded_Ref_Frame_Y;
    Decoded_Ref_Frame(:,:,2) = Decoded_Ref_Frame_Cb;
    Decoded_Ref_Frame(:,:,3) = Decoded_Ref_Frame_Cr;
end