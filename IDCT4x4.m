function [IDCT_Y IDCT_Cb IDCT_Cr] = IDCT4x4(InvQI_Y,InvQI_Cb,InvQI_Cr)

IDCT_Y_rows = idct(InvQI_Y');
IDCT_Y = idct(IDCT_Y_rows');
IDCT_Cb_rows = idct(InvQI_Cb');
IDCT_Cb = idct(IDCT_Cb_rows');
IDCT_Cr_rows = idct(InvQI_Cr');
IDCT_Cr = idct(IDCT_Cr_rows');
    
end
