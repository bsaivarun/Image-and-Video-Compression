function [QI_Y QI_Cb QI_Cr] = Quant4x4(DCT_Y,DCT_Cb,DCT_Cr,Scaling_Factor)

    Q_L =  [11 18 29 44; 18 27 40 56; 29 40 54 71; 44 56 71 90];
    Q_L = reshape(Q_L,[4 4]);
  

    QI_Y = round(DCT_Y./(Scaling_Factor.*Q_L));
    QI_Cb = round(DCT_Cb./(Scaling_Factor.*Q_L));
    QI_Cr = round(DCT_Cr./(Scaling_Factor.*Q_L));
    
end
