function Decoded_Ref_Frame = IntraDecode_YCbCr_SubPelChroma(zeroRun,Motion_Vector,Ref_Frame,Scaling_Factor,a,b)

    [FrameHeight FrameWidth FrameDim] = size(Ref_Frame);
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

    Motion_Vector_Y = Motion_Vector(1:1584,:);
    Motion_Vector_Cb = Motion_Vector(1585:1980,:);
    Motion_Vector_Cr = Motion_Vector(1981:end,:);
    zeroRunDec = ZeroRunDec_2(zeroRun);
    RLDec_Y = zeroRunDec(1,1:2*size(zeroRunDec,2)/3);
    RLDec_Cb = zeroRunDec(1,2*size(zeroRunDec,2)/3+1:2*size(zeroRunDec,2)/3+size(zeroRunDec,2)/6);
    RLDec_Cr = zeroRunDec(1,2*size(zeroRunDec,2)/3+size(zeroRunDec,2)/6+1:end);
    for k = 1:3
        if (k == 1)
            RefFrame = Ref_Frame_Y_SubPel;
            RLDec = RLDec_Y;
            Motion_Vector = Motion_Vector_Y;
        elseif (k == 2)
            RefFrame = Ref_Frame_Cb_SubPel;
            RLDec = RLDec_Cb;
            Motion_Vector = Motion_Vector_Cb;
        elseif (k == 3)
            RefFrame = Ref_Frame_Cr_SubPel ;
            RLDec = RLDec_Cr;
            Motion_Vector = Motion_Vector_Cr;
        end
        [FrameHeight FrameWidth FrameDim] = size(RefFrame);
        Block = 8;
        flag = 0;
        for i = 0:Block:FrameHeight-Block+1
            for j = 0:Block:FrameWidth-Block+1
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
                    Error_Ref_Frame_Y(i+1:i+Block,j+1:j+Block) = IDCT;
                    Corrected_i = i+Motion_Vector(flag,1);
                    Corrected_j = j+Motion_Vector(flag,2);


                    if((mod(Corrected_i,1) ~=0) || (mod(Corrected_j,1) ~=0))
                        Corrected_i = floor(Corrected_i);
                        Corrected_j = floor(Corrected_j);
                        Decoded_Ref_Frame_Y(i+1:i+8,j+1:j+8) = Error_Ref_Frame_Y(i+1:i+8,j+1:j+8) + Ref_Frame_Y_SubPel(Corrected_i+1:Corrected_i+8,Corrected_j+1:Corrected_j+8);
                    else
                        Decoded_Ref_Frame_Y(i+1:i+8,j+1:j+8) = Error_Ref_Frame_Y(i+1:i+8,j+1:j+8) + Ref_Frame_Y(Corrected_i+1:Corrected_i+8,Corrected_j+1:Corrected_j+8);
                    end               


                elseif (k == 2)
                    Error_Ref_Frame_Cb(i+1:i+Block,j+1:j+Block) = IDCT;
                    Corrected_i = i+Motion_Vector(flag,1);
                    Corrected_j = j+Motion_Vector(flag,2);
                    if((mod(Corrected_i,1) ~=0) || (mod(Corrected_j,1) ~=0))
                        Corrected_i = floor(Corrected_i);
                        Corrected_j = floor(Corrected_j);
                        Decoded_Ref_Frame_Cb(i+1:i+8,j+1:j+8) = Error_Ref_Frame_Cb(i+1:i+8,j+1:j+8) + Ref_Frame_Cb_SubPel(Corrected_i+1:Corrected_i+8,Corrected_j+1:Corrected_j+8);
                    else
                        Decoded_Ref_Frame_Cb(i+1:i+8,j+1:j+8) = Error_Ref_Frame_Cb(i+1:i+8,j+1:j+8) + Ref_Frame_Cb(Corrected_i+1:Corrected_i+8,Corrected_j+1:Corrected_j+8);
                    end

                elseif (k == 3)
                    Error_Ref_Frame_Cr(i+1:i+Block,j+1:j+Block) = IDCT;
                    Corrected_i = i+Motion_Vector(flag,1);
                    Corrected_j = j+Motion_Vector(flag,2);

                    if((mod(Corrected_i,1) ~=0) || (mod(Corrected_j,1) ~=0))
                        Corrected_i = floor(Corrected_i);
                        Corrected_j = floor(Corrected_j);
                        Decoded_Ref_Frame_Cr(i+1:i+8,j+1:j+8) = Error_Ref_Frame_Cr(i+1:i+8,j+1:j+8) + Ref_Frame_Cr_SubPel(Corrected_i+1:Corrected_i+8,Corrected_j+1:Corrected_j+8);
                    else
                        Decoded_Ref_Frame_Cr(i+1:i+8,j+1:j+8) = Error_Ref_Frame_Cr(i+1:i+8,j+1:j+8) + Ref_Frame_Cr(Corrected_i+1:Corrected_i+8,Corrected_j+1:Corrected_j+8);
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