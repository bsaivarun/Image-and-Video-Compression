function Decoded_Ref_Frame = IntraDecode_YCbCr_Chroma(zeroRun,Motion_Vector,Ref_Frame,Scaling_Factor)

    
    Ref_Frame_Y = Ref_Frame(:,:,1);
    Ref_Frame_Cb = Ref_Frame(:,:,2);
    Ref_Frame_Cr = Ref_Frame(:,:,3);
    Ref_Frame_Cb = transpose(resample(transpose(resample(Ref_Frame_Cb,1,2)),1,2));
    Ref_Frame_Cr = transpose(resample(transpose(resample(Ref_Frame_Cr,1,2)),1,2));
    Motion_Vector_Y = Motion_Vector(1:1584,:);
    Motion_Vector_Cb = Motion_Vector(1585:1980,:);
    Motion_Vector_Cr = Motion_Vector(1981:end,:);
    zeroRunDec = ZeroRunDec_2(zeroRun);
    RLDec_Y = zeroRunDec(1,1:2*size(zeroRunDec,2)/3);
    RLDec_Cb = zeroRunDec(1,2*size(zeroRunDec,2)/3+1:2*size(zeroRunDec,2)/3+size(zeroRunDec,2)/6);
    RLDec_Cr = zeroRunDec(1,2*size(zeroRunDec,2)/3+size(zeroRunDec,2)/6+1:end);
    for k = 1:3
        if (k == 1)
           RefFrame = Ref_Frame_Y;
           RLDec = RLDec_Y;
           Motion_Vector = Motion_Vector_Y;
        elseif (k == 2)
           RefFrame = Ref_Frame_Cb;
           RLDec = RLDec_Cb;
           Motion_Vector = Motion_Vector_Cb;
        elseif (k == 3)
           RefFrame = Ref_Frame_Cr;
           RLDec = RLDec_Cr;
           Motion_Vector = Motion_Vector_Cr;
        end
        [FrameHeight FrameWidth FrameDim] = size(RefFrame);
        Block = 8;
        flag = 0;
        for i = 1:Block:FrameHeight-Block+1
            for j = 1:Block:FrameWidth-Block+1
            %% RunLengthDecoding --> DeZigZagScan --> DeQuantization --> InverseDCT
            flag = flag+1;

            [DeZigZag_Y DeZigZag_Cb DeZigZag_Cr] = DeZigZag8x8(RLDec((flag-1)*64+1:flag*64),RLDec((flag-1)*64+1:flag*64),RLDec((flag-1)*64+1:flag*64));
            [DeQI_Y DeQI_Cb DeQI_Cr] = DeQuant8x8(DeZigZag_Y,DeZigZag_Cb,DeZigZag_Cr,Scaling_Factor);
            if (k == 1)
                DeQI = DeQI_Y;
            elseif (k == 2)
                DeQI = DeQI_Cb;
            elseif (k == 3)
                DeQI = DeQI_Cr;
            end
            [IDCT IDCT IDCT] = IDCT8x8(DeQI,DeQI,DeQI);
            %% Image Reconstruction
            
            if (k == 1)
                Error_Ref_Frame_Y(i:i+Block-1,j:j+Block-1) = IDCT;          
                Corrected_i = i+Motion_Vector(flag,1);
                Corrected_j = j+Motion_Vector(flag,2);
                Decoded_Ref_Frame_Y(i:i+7,j:j+7) = Error_Ref_Frame_Y(i:i+7,j:j+7) + RefFrame(Corrected_i:Corrected_i+7,Corrected_j:Corrected_j+7);
            elseif (k == 2)
                Error_Ref_Frame_Cb(i:i+Block-1,j:j+Block-1) = IDCT;
                Corrected_i = i+Motion_Vector(flag,1);
                Corrected_j = j+Motion_Vector(flag,2);
                Decoded_Ref_Frame_Cb(i:i+7,j:j+7) = Error_Ref_Frame_Cb(i:i+7,j:j+7) + RefFrame(Corrected_i:Corrected_i+7,Corrected_j:Corrected_j+7);
            elseif (k == 3)
                Error_Ref_Frame_Cr(i:i+Block-1,j:j+Block-1) = IDCT;
                Corrected_i = i+Motion_Vector(flag,1);
                Corrected_j = j+Motion_Vector(flag,2);
                Decoded_Ref_Frame_Cr(i:i+7,j:j+7) = Error_Ref_Frame_Cr(i:i+7,j:j+7) + RefFrame(Corrected_i:Corrected_i+7,Corrected_j:Corrected_j+7);
            end
            end
        end
    end
    Decoded_Ref_Frame(:,:,1) = Decoded_Ref_Frame_Y;
    Decoded_Ref_Frame_Cb = transpose(resample(transpose(resample(Decoded_Ref_Frame_Cb,2,1)),2,1));
    Decoded_Ref_Frame_Cr = transpose(resample(transpose(resample(Decoded_Ref_Frame_Cr,2,1)),2,1));
    Decoded_Ref_Frame(:,:,2) = Decoded_Ref_Frame_Cb;
    Decoded_Ref_Frame(:,:,3) = Decoded_Ref_Frame_Cr;
end