function [ZigZag_Y ZigZag_Cb ZigZag_Cr] = ZigZag8x8(QI_Y,QI_Cb,QI_Cr)
       
    ZigZag = [1 2 6 7 15 16 28 29;
                  3 5 8 14 17 27 30 43;
                  4 9 13 18 26 31 42 44;
                  10 12 19 25 32 41 45 54;
                  11 20 24 33 40 46 53 55;
                  21 23 34 39 47 52 56 61;
                  22 35 38 48 51 57 60 62;
                  36 37 49 50 58 59 63 64]; 
        
        input_Y = reshape(QI_Y,[8 8]);
        ZigZag_Y(ZigZag(:)) = input_Y;
        
        input_Cb = reshape(QI_Cb,[8 8]);
        ZigZag_Cb(ZigZag(:)) = input_Cb;
        
        input_Cr = reshape(QI_Cr,[8 8]);
        ZigZag_Cr(ZigZag(:)) = input_Cr;
%         ZigZag_Y = input_Y([1 9 2 3 10 17 25 18 11 4 15 12 19 26 33 41 34 27 20 13 6 7 14 21 28 35 42 49 57 50 43 36 ...
%                         29 22 15 8 16 23 30 37 44 51 58 59 52 45 38 31 24 32 39 46 53 60 61 54 47 40 48 55 62 63 56 64]);
%         input_Cb = reshape(QI_Cb,[8 8]);
%         ZigZag_Cb = input_Cb([1 9 2 3 10 17 25 18 11 4 15 12 19 26 33 41 34 27 20 13 6 7 14 21 28 35 42 49 57 50 43 36 ...
%                         29 22 15 8 16 23 30 37 44 51 58 59 52 45 38 31 24 32 39 46 53 60 61 54 47 40 48 55 62 63 56 64]);
%         input_Cr = reshape(QI_Cr,[8 8]);
%         ZigZag_Cr = input_Cr([1 9 2 3 10 17 25 18 11 4 15 12 19 26 33 41 34 27 20 13 6 7 14 21 28 35 42 49 57 50 43 36 ...
%                         29 22 15 8 16 23 30 37 44 51 58 59 52 45 38 31 24 32 39 46 53 60 61 54 47 40 48 55 62 63 56 64]);
end



% nhs = 0;
% nvs = 0;
% ndds = 0;
% ndus = 0;
% for i = 1:8
%     for j = 1:8
%     scan(1) = input(1);
%     if (mod(i+j-1,2) == 0)
%     scan(i+j-1) = input(i,j);
%     nhs = nhs+1;
%     elseif (mod(i+j-1,2) == 0)
%     end
%     end
%     
% end