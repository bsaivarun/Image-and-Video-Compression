function [RLEnc_Y RLEnc_Cb RLEnc_Cr] = ZeroRunEnc(ZigZag_Y,ZigZag_Cb,ZigZag_Cr)
    
EOB = 700;
    for k =1:3
        if k == 1
            value=[];
            ZigZag = ZigZag_Y;
        elseif k == 2
            value=[];
            ZigZag = ZigZag_Cb;
        elseif k == 3
            value=[];
            ZigZag = ZigZag_Cr;
        end
        loop =0;
        i = 1;
        while i <= size(ZigZag,2)

            current = ZigZag(i);
            loop = loop+1;
            value(1,loop) = current;
                if (current == 0)
                    run = 0;
                    if (find(ZigZag(i+1:end)~=0))
                        while ZigZag(i+1) == 0                
                            run = run + 1;
                            i = i+1;
                        end
                        value(1,loop+1) = run;
                        loop = loop+1;
%                     else
%                         value = value(1,1:end-1);
%                         break
                    end
                end
            i = i+1;
        end
        if k == 1
            RLEnc_Y = value;
            RLEnc_Y = RLEnc_Y(1:max(find(RLEnc_Y(1:end)~=0)));
            RLEnc_Y = [RLEnc_Y,EOB];
        elseif k == 2
            RLEnc_Cb = value;
            RLEnc_Cb = RLEnc_Cb(1:max(find(RLEnc_Cb(1:end)~=0)));
            RLEnc_Cb = [RLEnc_Cb,EOB];
        elseif k == 3
            RLEnc_Cr = value;
            RLEnc_Cr = RLEnc_Cr(1:max(find(RLEnc_Cr(1:end)~=0)));
            RLEnc_Cr = [RLEnc_Cr,EOB];
        end

    end
end

