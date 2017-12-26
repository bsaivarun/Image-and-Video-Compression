function Decoded_Ref_Frame = IntraDecode_YCbCr_SubPelMultiChroma(zeroRun,Motion_Vector,Ref_Frame,Scaling_Factor,MultipleFrame,a,b)

    [FrameHeight FrameWidth FrameDim] = size(Ref_Frame);
    if (MultipleFrame == 1)
        Ref_Frame_Y = Ref_Frame(:,:,1);
        Ref_Frame_Cb = Ref_Frame(:,:,2);
        Ref_Frame_Cr = Ref_Frame(:,:,3);
        
        Padd_Y = [Ref_Frame_Y Ref_Frame_Y(:,FrameWidth-1)];
        Padd_Y = [Padd_Y;Padd_Y(FrameHeight-1,:)];

        Ref_Frame_Y_SubPel = (1-b)*(1-a)*Padd_Y(1:FrameHeight,1:FrameWidth)+(1-b)*(a)*Padd_Y(1:FrameHeight,2:FrameWidth+1)+...
                              (b)*(1-a)*Padd_Y(2:FrameHeight+1,1:FrameWidth)+(b)*(a)*Padd_Y(2:FrameHeight+1,2:FrameWidth+1);

        Ref_Frame_Cb = transpose(resample(transpose(resample(Ref_Frame_Cb,1,2)),1,2));
        Ref_Frame_Cr = transpose(resample(transpose(resample(Ref_Frame_Cr,1,2)),1,2));
        [SubHeight SubWidth SubDim] = size(Ref_Frame_Cb);
        Padd_Cb = [Ref_Frame_Cb Ref_Frame_Cb(:,SubWidth-1)];
        Padd_Cb = [Padd_Cb;Padd_Cb(SubHeight-1,:)];
        Padd_Cr = [Ref_Frame_Cr Ref_Frame_Cr(:,SubWidth-1)];
        Padd_Cr = [Padd_Cr;Padd_Cr(SubHeight-1,:)];
        Ref_Frame_Cb_SubPel = (1-b)*(1-a)*Padd_Cb(1:SubHeight,1:SubWidth)+(1-b)*(a)*Padd_Cb(1:SubHeight,2:SubWidth+1)+...
                               (b)*(1-a)*Padd_Cb(2:SubHeight+1,1:SubWidth)+(b)*(a)*Padd_Cb(2:SubHeight+1,2:SubWidth+1);
        Ref_Frame_Cr_SubPel = (1-b)*(1-a)*Padd_Cr(1:SubHeight,1:SubWidth)+(1-b)*(a)*Padd_Cr(1:SubHeight,2:SubWidth+1)+...
                               (b)*(1-a)*Padd_Cr(2:SubHeight+1,1:SubWidth)+(b)*(a)*Padd_Cr(2:SubHeight+1,2:SubWidth+1);
       
    else
        FrameWidth = FrameWidth/2;
        Ref_Frame_Y = Ref_Frame(:,1:FrameWidth,1);
        Ref_Frame_Y_2 = Ref_Frame(:,FrameWidth+1:end,1);
        Ref_Frame_Cb = Ref_Frame(:,1:FrameWidth,2);
        Ref_Frame_Cb_2 = Ref_Frame(:,FrameWidth+1:end,2);
        Ref_Frame_Cr = Ref_Frame(:,1:FrameWidth,3);
        Ref_Frame_Cr_2 = Ref_Frame(:,FrameWidth+1:end,3);
        Padd_Y = [Ref_Frame_Y Ref_Frame_Y(:,FrameWidth-1)];
        Padd_Y = [Padd_Y;Padd_Y(FrameHeight-1,:)];
        Ref_Frame_Y_SubPel = (1-b)*(1-a)*Padd_Y(1:FrameHeight,1:FrameWidth)+(1-b)*(a)*Padd_Y(1:FrameHeight,2:FrameWidth+1)+...
                              (b)*(1-a)*Padd_Y(2:FrameHeight+1,1:FrameWidth)+(b)*(a)*Padd_Y(2:FrameHeight+1,2:FrameWidth+1);
        Ref_Frame_Cb = transpose(resample(transpose(resample(Ref_Frame_Cb,1,2)),1,2));
        Ref_Frame_Cr = transpose(resample(transpose(resample(Ref_Frame_Cr,1,2)),1,2));

        [SubHeight SubWidth SubDim] = size(Ref_Frame_Cb);

        Padd_Cb = [Ref_Frame_Cb Ref_Frame_Cb(:,SubWidth-1)];
        Padd_Cb = [Padd_Cb;Padd_Cb(SubHeight-1,:)];
        Padd_Cr = [Ref_Frame_Cr Ref_Frame_Cr(:,SubWidth-1)];
        Padd_Cr = [Padd_Cr;Padd_Cr(SubHeight-1,:)];
        Ref_Frame_Cb_SubPel = (1-b)*(1-a)*Padd_Cb(1:SubHeight,1:SubWidth)+(1-b)*(a)*Padd_Cb(1:SubHeight,2:SubWidth+1)+...
                               (b)*(1-a)*Padd_Cb(2:SubHeight+1,1:SubWidth)+(b)*(a)*Padd_Cb(2:SubHeight+1,2:SubWidth+1);
        Ref_Frame_Cr_SubPel = (1-b)*(1-a)*Padd_Cr(1:SubHeight,1:SubWidth)+(1-b)*(a)*Padd_Cr(1:SubHeight,2:SubWidth+1)+...
                               (b)*(1-a)*Padd_Cr(2:SubHeight+1,1:SubWidth)+(b)*(a)*Padd_Cr(2:SubHeight+1,2:SubWidth+1);

        Padd_Y_2 = [Ref_Frame_Y_2 Ref_Frame_Y_2(:,FrameWidth-1)];
        Padd_Y_2 = [Padd_Y_2;Padd_Y_2(FrameHeight-1,:)];
        Ref_Frame_Y_2_SubPel = (1-b)*(1-a)*Padd_Y_2(1:FrameHeight,1:FrameWidth)+(1-b)*(a)*Padd_Y_2(1:FrameHeight,2:FrameWidth+1)+...
                              (b)*(1-a)*Padd_Y_2(2:FrameHeight+1,1:FrameWidth)+(b)*(a)*Padd_Y_2(2:FrameHeight+1,2:FrameWidth+1);
        Ref_Frame_Cb_2 = transpose(resample(transpose(resample(Ref_Frame_Cb_2,1,2)),1,2));
        Ref_Frame_Cr_2 = transpose(resample(transpose(resample(Ref_Frame_Cr_2,1,2)),1,2));

        [SubHeight SubWidth SubDim] = size(Ref_Frame_Cb_2);

        Padd_Cb_2 = [Ref_Frame_Cb_2 Ref_Frame_Cb_2(:,SubWidth-1)];
        Padd_Cb_2 = [Padd_Cb_2;Padd_Cb_2(SubHeight-1,:)];
        Padd_Cr_2 = [Ref_Frame_Cr_2 Ref_Frame_Cr_2(:,SubWidth-1)];
        Padd_Cr_2 = [Padd_Cr_2;Padd_Cr_2(SubHeight-1,:)];
        Ref_Frame_Cb_2_SubPel = (1-b)*(1-a)*Padd_Cb_2(1:SubHeight,1:SubWidth)+(1-b)*(a)*Padd_Cb_2(1:SubHeight,2:SubWidth+1)+...
                               (b)*(1-a)*Padd_Cb_2(2:SubHeight+1,1:SubWidth)+(b)*(a)*Padd_Cb_2(2:SubHeight+1,2:SubWidth+1);
        Ref_Frame_Cr_2_SubPel = (1-b)*(1-a)*Padd_Cr_2(1:SubHeight,1:SubWidth)+(1-b)*(a)*Padd_Cr_2(1:SubHeight,2:SubWidth+1)+...
                               (b)*(1-a)*Padd_Cr_2(2:SubHeight+1,1:SubWidth)+(b)*(a)*Padd_Cr_2(2:SubHeight+1,2:SubWidth+1);
    
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
           RefFrame_1 = Ref_Frame_Y;
           RLDec = RLDec_Y;
           RefFrame_1_SubPel = Ref_Frame_Y_SubPel;
            if (MultipleFrame == 2)
                RefFrame_2 = Ref_Frame_Y_2;
                RefFrame_2_SubPel = Ref_Frame_Y_2_SubPel;
            end
           Motion_Vector = Motion_Vector_Y;
        elseif (k == 2)
           RefFrame_1 = Ref_Frame_Cb;
           RLDec = RLDec_Cb;
           RefFrame_1_SubPel = Ref_Frame_Cb_SubPel;
           if (MultipleFrame == 2)
                RefFrame_2 = Ref_Frame_Cb_2;
                RefFrame_2_SubPel = Ref_Frame_Cb_2_SubPel;
            end
           Motion_Vector = Motion_Vector_Cb;
        elseif (k == 3)
           RefFrame_1 = Ref_Frame_Cr;
           RLDec = RLDec_Cr;
           RefFrame_1_SubPel = Ref_Frame_Cr_SubPel;
           if (MultipleFrame == 2)
                RefFrame_2 = Ref_Frame_Cr_2;
                RefFrame_2_SubPel = Ref_Frame_Cr_2_SubPel;
            end
           Motion_Vector = Motion_Vector_Cr;
        end
        [FrameHeight FrameWidth FrameDim] = size(RefFrame_1);
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
            [IDCT_Y IDCT_Cb IDCT_Cr] = IDCT8x8(DeQI,DeQI,DeQI);
            %% Image Reconstruction
            
            Corrected_i = i+Motion_Vector(flag,1);
            Corrected_j = j+Motion_Vector(flag,2);
            Corrected_Frame = Motion_Vector(flag,3);
            if (k == 1)
                Error_Ref_Frame(i:i+Block-1,j:j+Block-1) = IDCT_Y;
                if((mod(Corrected_i,1) ~=0) || (mod(Corrected_j,1) ~=0))
                    Corrected_i = floor(Corrected_i);
                    Corrected_j = floor(Corrected_j);
                    if (Corrected_Frame == 1)
                        RefFrame = RefFrame_1_SubPel;
                    elseif (Corrected_Frame == 2)
                        RefFrame = RefFrame_2_SubPel;
                    end
                else
                    if (Corrected_Frame == 1)
                        RefFrame = RefFrame_1;
                    elseif (Corrected_Frame == 2)
                        RefFrame = RefFrame_2;
                    end
                end
                Decoded_Ref_Frame_Y(i:i+7,j:j+7) = Error_Ref_Frame(i:i+7,j:j+7) + RefFrame(Corrected_i:Corrected_i+7,Corrected_j:Corrected_j+7);
            elseif (k == 2)
                Error_Ref_Frame(i:i+Block-1,j:j+Block-1) = IDCT_Cb;
                if((mod(Corrected_i,1) ~=0) || (mod(Corrected_j,1) ~=0))
                    Corrected_i = floor(Corrected_i);
                    Corrected_j = floor(Corrected_j);
                    if (Corrected_Frame == 1)
                        RefFrame = RefFrame_1_SubPel;
                    elseif (Corrected_Frame == 2)
                        RefFrame = RefFrame_2_SubPel;
                    end
                else
                    if (Corrected_Frame == 1)
                        RefFrame = RefFrame_1;
                    elseif (Corrected_Frame == 2)
                        RefFrame = RefFrame_2;
                    end
                end
                Decoded_Ref_Frame_Cb(i:i+7,j:j+7) = Error_Ref_Frame(i:i+7,j:j+7) + RefFrame(Corrected_i:Corrected_i+7,Corrected_j:Corrected_j+7);
            elseif (k == 3)
                Error_Ref_Frame(i:i+Block-1,j:j+Block-1) = IDCT_Cr;
                if((mod(Corrected_i,1) ~=0) || (mod(Corrected_j,1) ~=0))
                    Corrected_i = floor(Corrected_i);
                    Corrected_j = floor(Corrected_j);
                    if (Corrected_Frame == 1)
                        RefFrame = RefFrame_1_SubPel;
                    elseif (Corrected_Frame == 2)
                        RefFrame = RefFrame_2_SubPel;
                    end
                else
                    if (Corrected_Frame == 1)
                        RefFrame = RefFrame_1;
                    elseif (Corrected_Frame == 2)
                        RefFrame = RefFrame_2;
                    end
                end
                Decoded_Ref_Frame_Cr(i:i+7,j:j+7) = Error_Ref_Frame(i:i+7,j:j+7) + RefFrame(Corrected_i:Corrected_i+7,Corrected_j:Corrected_j+7);
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