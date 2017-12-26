function RLEnc_Full = IntraEncode_YCbCr_Chroma(Error_Frame_Y,Error_Frame_Cb,Error_Frame_Cr,Scaling_Factor)

    for k = 1:3
        if (k == 1)
            Error_Frame = Error_Frame_Y;
        elseif (k == 2)
            Error_Frame = Error_Frame_Cb;
        elseif (k == 3)
            Error_Frame = Error_Frame_Cr;
        end
        [ImageHeight ImageWidth ImageDim] = size(Error_Frame);
        Block = 8;
        flag = 0;
        for i = 0:Block:ImageHeight-Block
            for j = 0:Block:ImageWidth-Block
                flag = flag+1;
                VectorBlock = Error_Frame(i+1:i+Block,j+1:j+Block);

                %% DCT --> Quantization --> ZigZagScan --> RunLengthCoding
                [DCT_Y DCT_Cb DCT_Cr] = DCT8x8(VectorBlock,VectorBlock,VectorBlock);
                [QI_Y QI_Cb QI_Cr] = Quant8x8(DCT_Y,DCT_Cb,DCT_Cr,Scaling_Factor);
                if (k == 1)
                    QI = QI_Y;
                elseif (k == 2)
                    QI = QI_Cb;
                elseif (k == 3)
                    QI = QI_Cr;
                end
                [ZigZag ZigZag ZigZag] = ZigZag8x8(QI,QI,QI);
                [RLEnc RLEnc RLEnc] = ZeroRunEnc(ZigZag,ZigZag,ZigZag);

                %% Merging the data for whole image
                if ( i == 0 && j == 0)
                    RLEnc_Full = RLEnc;
                else
                RLEnc_Full = [RLEnc_Full,RLEnc];
                end      
            end
        end
        if (k == 1)
            RLEnc_Y_Full = RLEnc_Full;
        elseif (k == 2)
            RLEnc_Cb_Full = RLEnc_Full;
        elseif (k == 3)
            RLEnc_Cr_Full = RLEnc_Full;
        end
    end
    RLEnc_Full = [RLEnc_Y_Full,RLEnc_Cb_Full,RLEnc_Cr_Full];
end