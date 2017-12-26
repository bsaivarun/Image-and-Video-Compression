function [DeQI_Y DeQI_Cb DeQI_Cr] = DeQuant4x4(DeZigZag_Y,DeZigZag_Cb,DeZigZag_Cr,Scaling_Factor)

    Q_L = [11 18 29 44; 18 27 40 56; 29 40 54 71; 44 56 71 90];
    Q_L = reshape(Q_L,[4 4]);
    
    DeZigZag_Y = reshape(DeZigZag_Y,[4 4]);
    DeZigZag_Cb = reshape(DeZigZag_Cb,[4 4]);
    DeZigZag_Cr = reshape(DeZigZag_Cr,[4 4]);
    
    DeQI_Y = (Scaling_Factor.*Q_L).*DeZigZag_Y;
    DeQI_Cb =(Scaling_Factor.*Q_L).*DeZigZag_Cb;
    DeQI_Cr =(Scaling_Factor.*Q_L).*DeZigZag_Cr;
end
