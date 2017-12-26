function [RLEnc_Full pcdm_Full]= IntraEncode_YCbCr_AC_DC(Error_Frame_YCbCr,Scaling_Factor,iframes)

[ImageHeight ImageWidth ImageDim] = size(Error_Frame_YCbCr);
Error_Frame_Y = Error_Frame_YCbCr(:,:,1);
Error_Frame_Cb = Error_Frame_YCbCr(:,:,2);
Error_Frame_Cr = Error_Frame_YCbCr(:,:,3);
Block = 8;
flag = 0;
ZigZag_Ydc_total=[];
Previous_Y_DC=0;
Previous_Cb_DC=0;
Previous_Cr_DC=0;

for i = 0:Block:ImageHeight-Block
    for j = 0:Block:ImageWidth-Block
        flag = flag+1;
        VectorBlock_Y = Error_Frame_Y(i+1:i+Block,j+1:j+Block);
        VectorBlock_Cb = Error_Frame_Cb(i+1:i+Block,j+1:j+Block);
        VectorBlock_Cr = Error_Frame_Cr(i+1:i+Block,j+1:j+Block);
        
        %% DCT --> Quantization --> ZigZagScan --> RunLengthCoding
        [DCT_Y DCT_Cb DCT_Cr] = DCT8x8(VectorBlock_Y,VectorBlock_Cb,VectorBlock_Cr);
        [QI_Y QI_Cb QI_Cr] = Quant8x8(DCT_Y,DCT_Cb,DCT_Cr,Scaling_Factor);
        [ZigZag_Y ZigZag_Cb ZigZag_Cr] = ZigZag8x8(QI_Y,QI_Cb,QI_Cr);
        ZigZag_Ydc_total=[ZigZag_Ydc_total ZigZag_Y(1,1)];
        
        ZigZag_Y_DC=ZigZag_Y(1,1)-Previous_Y_DC;
        ZigZag_Cb_DC=ZigZag_Cb(1,1)-Previous_Cb_DC;
        ZigZag_Cr_DC=ZigZag_Cr(1,1)-Previous_Cr_DC;
        Previous_Y_DC=ZigZag_Y(1,1);
        Previous_Cb_DC=ZigZag_Cb(1,1);
        Previous_Cr_DC=ZigZag_Cr(1,1);
        
        
        ZigZag_Y_AC=ZigZag_Y(1,2:Block*Block);
        ZigZag_Cb_AC=ZigZag_Cb(1,2:Block*Block);
        ZigZag_Cr_AC=ZigZag_Cr(1,2:Block*Block);
        
        [RLEnc_Y RLEnc_Cb RLEnc_Cr] = ZeroRunEnc(ZigZag_Y_AC,ZigZag_Cb_AC,ZigZag_Cr_AC);
        
        %% Merging the data for whole image
        if ( i == 0 && j == 0)
            RLEnc_Y_Full = RLEnc_Y;
            RLEnc_Cb_Full = RLEnc_Cb;
            RLEnc_Cr_Full = RLEnc_Cr;
            
            ZigZag_Y_DC_Full=ZigZag_Y_DC;
            ZigZag_Cr_DC_Full=ZigZag_Cr_DC;
            ZigZag_Cb_DC_Full=ZigZag_Cb_DC;
        else
            RLEnc_Y_Full = [RLEnc_Y_Full,RLEnc_Y];
            RLEnc_Cb_Full = [RLEnc_Cb_Full,RLEnc_Cb];
            RLEnc_Cr_Full = [RLEnc_Cr_Full,RLEnc_Cr];
            
            ZigZag_Y_DC_Full=[ZigZag_Y_DC_Full ZigZag_Y_DC];
            ZigZag_Cr_DC_Full=[ZigZag_Cr_DC_Full ZigZag_Cr_DC];
            ZigZag_Cb_DC_Full=[ZigZag_Cb_DC_Full ZigZag_Cb_DC];
            
        end
    end
end
RLEnc_Full = [RLEnc_Y_Full,RLEnc_Cb_Full,RLEnc_Cr_Full];
pcdm_Full=[ ZigZag_Y_DC_Full, ZigZag_Cb_DC_Full, ZigZag_Cr_DC_Full];
end