function [IT_Y IT_Cb IT_Cr] = IT4x4(VectorBlock_Y,VectorBlock_Cb,VectorBlock_Cr)

a = 1/4;
b = 1/10;
c = sqrt(1/40);

E = [a c a c
     c b c b
     a c a c
     c b c b];

C =  [1 1 1 1
      2 1 -1 -2
      1 -1 -1 1
      1 -2 2 -1];

IT_Y = (C*VectorBlock_Y*C').*E;
IT_Cb = (C*VectorBlock_Cb*C').*E;
IT_Cr = (C*VectorBlock_Cr*C').*E;

end