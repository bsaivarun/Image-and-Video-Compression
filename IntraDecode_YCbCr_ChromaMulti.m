function Decoded_Ref_Frame = IntraDecode_YCbCr_ChromaMulti(zeroRun,Motion_Vector,Ref_Frame,Scaling_Factor,MultipleFrame)
% load naina.mat
% MultipleFrame=MR;
if (MultipleFrame == 1)
    [FrameHeight FrameWidth FrameDim] = size(Ref_Frame);
    Ref_Frame_Y_1 = Ref_Frame(:,:,1);
    Ref_Frame_Cb_1 = Ref_Frame(:,:,2);
    Ref_Frame_Cr_1 = Ref_Frame(:,:,3);
    Ref_Frame_Cb_1 = transpose(resample(transpose(resample(Ref_Frame_Cb_1,1,2)),1,2));
    Ref_Frame_Cr_1 = transpose(resample(transpose(resample(Ref_Frame_Cr_1,1,2)),1,2));
else
    [FrameHeight FrameWidth FrameDim] = size(Ref_Frame);
    FrameWidth = FrameWidth/MultipleFrame;
    Ref_Frame_Y_1 = Ref_Frame(:,1:FrameWidth,1);
    Ref_Frame_Cb_1 = Ref_Frame(:,1:FrameWidth,2);
    Ref_Frame_Cr_1 = Ref_Frame(:,1:FrameWidth,3);
    Ref_Frame_Cb_1 = transpose(resample(transpose(resample(Ref_Frame_Cb_1,1,2)),1,2));
    Ref_Frame_Cr_1 = transpose(resample(transpose(resample(Ref_Frame_Cr_1,1,2)),1,2));
    
    Ref_Frame_Y_2 = Ref_Frame(:,FrameWidth+1:end,1);
    Ref_Frame_Cb_2 = Ref_Frame(:,FrameWidth+1:end,2);
    Ref_Frame_Cr_2 = Ref_Frame(:,FrameWidth+1:end,3);
    Ref_Frame_Cb_2 = transpose(resample(transpose(resample(Ref_Frame_Cb_2,1,2)),1,2));
    Ref_Frame_Cr_2 = transpose(resample(transpose(resample(Ref_Frame_Cr_2,1,2)),1,2));
end


Motion_Vector_Y = Motion_Vector(1:1584,:);
Motion_Vector_Cb = Motion_Vector(1585:1980,:);
Motion_Vector_Cr = Motion_Vector(1981:end,:);
zeroRunDec = ZeroRunDec_2(zeroRun);
RLDec_Y = zeroRunDec(1,1:2*size(zeroRunDec,2)/3);
RLDec_Cb = zeroRunDec(1,2*size(zeroRunDec,2)/3+1:2*size(zeroRunDec,2)/3+size(zeroRunDec,2)/6);
RLDec_Cr = zeroRunDec(1,2*size(zeroRunDec,2)/3+size(zeroRunDec,2)/6+1:end);
for k = 1:3
    if (k == 1)
        if (MultipleFrame == 1)
            RefFrame = Ref_Frame_Y_1;
            RLDec = RLDec_Y;
            Motion_Vector = Motion_Vector_Y;
        else
            RefFrame = Ref_Frame_Y_1;
            RLDec = RLDec_Y;
            Motion_Vector = Motion_Vector_Y;
            RefFrame_2 = Ref_Frame_Y_2;
        end
    elseif (k == 2)
        if (MultipleFrame == 1)
            RefFrame = Ref_Frame_Cb_1;
            RLDec = RLDec_Cb;
            Motion_Vector = Motion_Vector_Cb;
        else
            RefFrame = Ref_Frame_Cb_1;
            RLDec = RLDec_Cb;
            Motion_Vector = Motion_Vector_Cb;
            RefFrame_2 = Ref_Frame_Cb_2;
        end
    elseif (k == 3)
        if (MultipleFrame == 1)
            RefFrame = Ref_Frame_Cr_1;
            RLDec = RLDec_Cr;
            Motion_Vector = Motion_Vector_Cr;
        else
            RefFrame = Ref_Frame_Cr_1;
            RLDec = RLDec_Cr;
            Motion_Vector = Motion_Vector_Cr;
            RefFrame_2 = Ref_Frame_Cr_2;
        end
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
                Corrected_Frame = Motion_Vector(flag,3);
                if (Corrected_Frame == 1)
                    Decoded_Ref_Frame_Y(i:i+7,j:j+7) = Error_Ref_Frame_Y(i:i+7,j:j+7) + RefFrame(Corrected_i:Corrected_i+7,Corrected_j:Corrected_j+7);
                else
                    Decoded_Ref_Frame_Y(i:i+7,j:j+7) = Error_Ref_Frame_Y(i:i+7,j:j+7) + RefFrame_2(Corrected_i:Corrected_i+7,Corrected_j:Corrected_j+7);
                end
            elseif (k == 2)
                Error_Ref_Frame_Cb(i:i+Block-1,j:j+Block-1) = IDCT;
                Corrected_i = i+Motion_Vector(flag,1);
                Corrected_j = j+Motion_Vector(flag,2);
                Corrected_Frame = Motion_Vector(flag,3);
                if (Corrected_Frame == 1)
                    Decoded_Ref_Frame_Cb(i:i+7,j:j+7) = Error_Ref_Frame_Cb(i:i+7,j:j+7) + RefFrame(Corrected_i:Corrected_i+7,Corrected_j:Corrected_j+7);
                else
                    Decoded_Ref_Frame_Cb(i:i+7,j:j+7) = Error_Ref_Frame_Cb(i:i+7,j:j+7) + RefFrame_2(Corrected_i:Corrected_i+7,Corrected_j:Corrected_j+7);
                end
            elseif (k == 3)
                Error_Ref_Frame_Cr(i:i+Block-1,j:j+Block-1) = IDCT;
                Corrected_i = i+Motion_Vector(flag,1);
                Corrected_j = j+Motion_Vector(flag,2);
                Corrected_Frame = Motion_Vector(flag,3);
                if (Corrected_Frame == 1)
                    Decoded_Ref_Frame_Cr(i:i+7,j:j+7) = Error_Ref_Frame_Cr(i:i+7,j:j+7) + RefFrame(Corrected_i:Corrected_i+7,Corrected_j:Corrected_j+7);
                else
                    Decoded_Ref_Frame_Cr(i:i+7,j:j+7) = Error_Ref_Frame_Cr(i:i+7,j:j+7) + RefFrame_2(Corrected_i:Corrected_i+7,Corrected_j:Corrected_j+7);
                end
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