function RLEnc_Full = IntraEncode_YCbCr_Integer(Error_Frame_YCbCr,Scaling_Factor,OptimizationScheme,EOB)
RLEnc_Y_Full=[]; RLEnc_Cb_Full=0; RLEnc_Cr_Full=0;
[ImageHeight ImageWidth ImageDim] = size(Error_Frame_YCbCr);
Error_Frame_Y = Error_Frame_YCbCr(:,:,1);
Error_Frame_Cb = Error_Frame_YCbCr(:,:,2);
Error_Frame_Cr = Error_Frame_YCbCr(:,:,3);
Block = 4;
flag = 0;

    for i = 0:Block:ImageHeight-Block
        for j = 0:Block:ImageWidth-Block
            flag = flag+1;
            VectorBlock_Y = Error_Frame_Y(i+1:i+Block,j+1:j+Block);
            VectorBlock_Cb = Error_Frame_Cb(i+1:i+Block,j+1:j+Block);
            VectorBlock_Cr = Error_Frame_Cr(i+1:i+Block,j+1:j+Block);
            
            % DCT --> Quantization --> ZigZagScan --> RunLengthCoding
            if ( OptimizationScheme==1)
                 [DCT_Y DCT_Cb DCT_Cr] = DCT4x4(VectorBlock_Y,VectorBlock_Cb,VectorBlock_Cr);
            elseif ( OptimizationScheme==2)
            [DCT_Y DCT_Cb DCT_Cr] = IT4x4(VectorBlock_Y,VectorBlock_Cb,VectorBlock_Cr);
            end
            [QI_Y QI_Cb QI_Cr] = Quant4x4(DCT_Y,DCT_Cb,DCT_Cr,Scaling_Factor);
            [ZigZag_Y ZigZag_Cb ZigZag_Cr] = ZigZag4x4(QI_Y,QI_Cb,QI_Cr);
            [RLEnc_Y RLEnc_Cb RLEnc_Cr] = ZeroRunEnc4x4(ZigZag_Y,ZigZag_Cb,ZigZag_Cr,EOB);
            
            % Merging the data for whole image
            if ( i == 0 && j == 0)
                RLEnc_Y_Full = RLEnc_Y;
                RLEnc_Cb_Full = RLEnc_Cb;
                RLEnc_Cr_Full = RLEnc_Cr;
            else
            RLEnc_Y_Full = [RLEnc_Y_Full,RLEnc_Y];
            RLEnc_Cb_Full = [RLEnc_Cb_Full,RLEnc_Cb];
            RLEnc_Cr_Full = [RLEnc_Cr_Full,RLEnc_Cr];
            end      
        end
    end
    RLEnc_Full = [RLEnc_Y_Full,RLEnc_Cb_Full,RLEnc_Cr_Full];
    
end