function [DeQI_Y DeQI_Cb DeQI_Cr] = DeQuant8x8(DeZigZag_Y,DeZigZag_Cb,DeZigZag_Cr,Scaling_Factor)


    Q_L = [16 12 14 14 18 24 49 72 11 12 13 17 55 35 64 92 10 14 16 22 37 55 78 95 16 19 24 29 56 64 87 98 ...
           24 26 40 51 68 81 103 112 40 58 57 87 109 104 121 100 51 60 69 80 103 113 120 103 61 55 56 62 77 92 101 99];

    Q_C = [17 18 24 47 99 99 99 99 18 21 13 66 99 99 99 99 24 26 56 99 99 99 99 99 47 66 99 99 99 99 99 99 ...
           99 99 99 99 99 99 99 99 99 99 99 99 99 99 99 99 99 99 99 99 99 99 99 99 99 99 99 99 99 99 99 99];

    Q_L = reshape(Q_L,[8 8]);
    Q_C = reshape(Q_C,[8 8]);
    
    DeZigZag_Y = reshape(DeZigZag_Y,[8 8]);
    DeZigZag_Cb = reshape(DeZigZag_Cb,[8 8]);
    DeZigZag_Cr = reshape(DeZigZag_Cr,[8 8]);
    
    DeQI_Y = (Scaling_Factor.*Q_L).*DeZigZag_Y;
    DeQI_Cb =(Scaling_Factor.*Q_C).*DeZigZag_Cb;
    DeQI_Cr =(Scaling_Factor.*Q_C).*DeZigZag_Cr;
end
