function [IIT_Y, IIT_Cb, IIT_Cr] = IIT4x4(VectorBlock_Y,VectorBlock_Cb,VectorBlock_Cr)

a = 1/4;
b = 1/10;
c = sqrt(1/40);

E = [a c a c
     c b c b
     a c a c
     c b c b];


Ci =  [1 1 1 1
      1 1/2 -1/2 -1
      1 -1 -1 1
      1/2 -1 1 -1/2];
  
IIT_Y = Ci'*(VectorBlock_Y.*E)*Ci;
IIT_Cb = Ci'*(VectorBlock_Cb.*E)*Ci;
IIT_Cr = Ci'*(VectorBlock_Cr.*E)*Ci;

end