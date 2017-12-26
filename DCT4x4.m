function [DCT_Y DCT_Cb DCT_Cr] = DCT4x4(VectorBlock_Y,VectorBlock_Cb,VectorBlock_Cr)

DCT_Y_rows = dct(VectorBlock_Y');
DCT_Y = dct(DCT_Y_rows');
DCT_Cb_rows = dct(VectorBlock_Cb');
DCT_Cb = dct(DCT_Cb_rows');
DCT_Cr_rows = dct(VectorBlock_Cr');
DCT_Cr = dct(DCT_Cr_rows');

end