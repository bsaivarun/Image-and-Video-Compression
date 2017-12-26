function [RLDec_Y RLDec_Cb RLDec_Cr] = ZeroRunDec(Reconstructed_Data_Y,Reconstructed_Data_Cb,Reconstructed_Data_Cr)

    for k =1:3
        if k == 1
            Reconstructed_Data = Reconstructed_Data_Y;
        elseif k == 2
            Reconstructed_Data = Reconstructed_Data_Cb;
        elseif k == 3
            Reconstructed_Data = Reconstructed_Data_Cr;
        end
        loop = 0;
        i = 1;
        value = 0;
        while i <= size(Reconstructed_Data,2)

            current = Reconstructed_Data(i);
            loop = loop+1;
            value(1,loop) = current;
                if (current == 0)
                    run = Reconstructed_Data(i+1);
                    value(1,loop+1:loop+run) = current;
                    loop = loop+run;
                    i = i+1;
                end
            i = i+1;
        end
        if k == 1
            RLDec_Y = value;
            RLDec_Y(max(size(RLDec_Y,2)+1:64)) = 0;
        elseif k == 2
            RLDec_Cb = value;
            RLDec_Cb(max(size(RLDec_Cb,2)+1:64)) = 0;
        elseif k == 3
            RLDec_Cr = value;
            RLDec_Cr(max(size(RLDec_Cr,2)+1:64)) = 0;
        end

    end
end