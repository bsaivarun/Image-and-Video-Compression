function RLDec_Full = ZeroRunDec_AC_DC(Reconstructed_Data,Reconstructed_Data_PCDM)

[Value Index] = find(Reconstructed_Data==700);
for k = 1:size(Index,2)
    %% Getting Decoded data of 8x8 Block
    
    if k == 1
        data = Reconstructed_Data(1:Index(k)-1);
    else
        data = Reconstructed_Data(Index(k-1)+1:Index(k)-1);
    end
        
        loop = 0;
        i = 1;
        value = 0;
        while i <= size(data,2)

            current = data(i);
            loop = loop+1;
            value(1,loop) = current;
                if (current == 0)
                    run = data(i+1);
                    value(1,loop+1:loop+run) = current;
                    loop = loop+run;
                    i = i+1;
                end
            i = i+1;
        end
    % i added this-----------------------------
    if (k==1)
        DC(k)=Reconstructed_Data_PCDM(k);
    elseif (k == 1585)
        DC(k)=Reconstructed_Data_PCDM(k);
    elseif (k == 3169)
        DC(k)=Reconstructed_Data_PCDM(k);
    else
        DC(k)=Reconstructed_Data_PCDM(k)+DC(k-1);
    end
    %%%-----------------------
    RLDec=[DC(k) value];
    RLDec(max(size(RLDec,2)+1:64)) = 0;
    if k == 1
        RLDec_Full = RLDec;
    else
        RLDec_Full = [RLDec_Full,RLDec];                      
    end
    
end
end