function [DeZigZag_Y DeZigZag_Cb DeZigZag_Cr] = deZigZag4x4(RLDec_Y,RLDec_Cb,RLDec_Cr)

    ZigZag = [1 2 6 7; 3 5 8 13; 4 9 12 14; 10 11 15 16];
    DeZigZag_Y = RLDec_Y(ZigZag);
    DeZigZag_Cb = RLDec_Cb(ZigZag);
    DeZigZag_Cr = RLDec_Cr(ZigZag);

    DeZigZag_Y = reshape(DeZigZag_Y,4,4);
    DeZigZag_Cb = reshape(DeZigZag_Cb,4,4);
    DeZigZag_Cr = reshape(DeZigZag_Cr,4,4);
            
end