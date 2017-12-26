function [ZigZag_Y ZigZag_Cb ZigZag_Cr] = ZigZag4x3(QI_Y,QI_Cb,QI_Cr)
     
ZigZag=[1 2 6 7; 3 5 8 13; 4 9 12 14; 10 11 15 16];


  input_Y = reshape(QI_Y,[4 4]);
        ZigZag_Y(ZigZag(:)) = input_Y;
        
        input_Cb = reshape(QI_Cb,[4 4]);
        ZigZag_Cb(ZigZag(:)) = input_Cb;
        
        input_Cr = reshape(QI_Cr,[4 4]);
        ZigZag_Cr(ZigZag(:)) = input_Cr;

end




%     ZigZag = [1,1;1,2;2,1;3,1;2,2;1,3;1,4;2,3;3,2;4,1;4,2;3,3;2,4;3,4;4,3;4,4];
%     for i=1:16
%    m=ZigZag(i,1);
%    n=ZigZag(i,2);
%    l(i)=QI_Y(m,n); % l contains the reordered data
%     end
   
        
        




