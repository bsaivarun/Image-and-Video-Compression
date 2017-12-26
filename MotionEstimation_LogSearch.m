function [Error_Frame_Y Error_Frame_Cb Error_Frame_Cr Motion_Vector] = MotionEstimation_LogSearch(Current_Frame_YCbCr,Ref_Frame,BlockSize,SearchRange)

        [FrameHeight FrameWidth FrameDim] = size(Ref_Frame);
        Current_Frame_Y = Current_Frame_YCbCr(:,:,1);
        Current_Frame_Cb = Current_Frame_YCbCr(:,:,2);
        Current_Frame_Cr = Current_Frame_YCbCr(:,:,3);
        Ref_Frame_Y = Ref_Frame(:,:,1);
        Ref_Frame_Cb = Ref_Frame(:,:,2);
        Ref_Frame_Cr = Ref_Frame(:,:,3);
        flag = 0;
        loop = 0;
        Motion_Vector = zeros(FrameHeight*FrameWidth/BlockSize^2,2);
        for i = 1:BlockSize:FrameHeight-BlockSize+1
            for j = 1:BlockSize:FrameWidth-BlockSize+1
                flag = flag+1;
                %% Current Frame 8x8 Block
                Current_Frame_Block = Current_Frame_Y(i:i+BlockSize-1,j:j+BlockSize-1);
                Current_Frame_Block_Index = [i j];

                %% Previous Frame 8x8 Block
                Ref_Frame_Block = Ref_Frame_Y(i:i+BlockSize-1,j:j+BlockSize-1);

                %% +/- 4 pixels each size in previous frame
                SW_row_Low = i-SearchRange;
                SW_row_High = i+SearchRange;
                SW_col_Low = j-SearchRange;
                SW_col_High = j+SearchRange;
                if (SW_row_Low <= 1)
                    SW_row_Low = i;
                end
                if (SW_row_High >= FrameHeight)
                    SW_row_High = FrameHeight;
                end
                if (SW_col_Low <= 1)
                    SW_col_Low = j;
                end
                if (SW_col_High >= FrameWidth)
                    SW_col_High = FrameWidth;
                end
                SearchWindow = Ref_Frame_Y(SW_row_Low:SW_row_High,SW_col_Low:SW_col_High);

                %% Previous Frame 8x8 Block
                num=2; minimumSSD=inf;
                centerx=i; centery=j;
                cx = centerx; cy = centery;
                condition=10; SSD=inf;
                while (condition>0)
                    for indx=-num:num:num
                        indy=0;
                        if  centerx+indx<=FrameHeight && centerx+indx+BlockSize-1<=FrameHeight && centerx+indx>=SW_row_Low && centerx+indx<=SW_row_High 

                            Ref_Frame_Block = Ref_Frame_Y(centerx+indx:centerx+indx+BlockSize-1,centery+indy:centery+indy+BlockSize-1);
                            Difference = (Current_Frame_Block - Ref_Frame_Block).^2;
                            SSD_new = sum(sum(Difference(:)));
                            if(SSD_new < SSD)
                                SSD = SSD_new;
                                Min_SSD_Index = [centerx+indx centery+indy];
                            end
                        end
                    end
                    for indy=-num:2*num:num
                        indx=0;
                        if (centery+indy<=FrameWidth)&& (centery+indy+BlockSize-1<=FrameWidth) &&(centery+indy>=SW_col_Low && centery+indy<=SW_col_High)
                            indx=0;
                            Ref_Frame_Block = Ref_Frame_Y(centerx+indx:centerx+indx+BlockSize-1 , centery+indy:centery+indy+BlockSize-1);
                            Difference = (Current_Frame_Block - Ref_Frame_Block).^2;
                            SSD_new = sum(sum(Difference(:)));
                            if(SSD_new < SSD)
                                SSD = SSD_new;
                                Min_SSD_Index = [centerx+indx centery+indy];
                            end
                        end
                    end
                    if(minimumSSD <= SSD)
                        condition=0;
%                            centery=centery+indy;   centerx=centerx+indx;
                       centerx=cx; centery=cy;
                    else
                        minimumSSD=SSD;
                        centerx=Min_SSD_Index(1,1); centery=Min_SSD_Index(1,2);
                        condition=10;
                        cx = centerx;
                        cy = centery;
                    end
                end

                %% precision of the error----------------
                num=1;
                for indx=-num:num:num
                    for indy=-num:num:num
                        if ((abs(indx)+abs(indy))~=0)
                            if (centery+indy<=FrameWidth &&(centery+indy+BlockSize-1>0 && centery+indy+BlockSize-1<=FrameWidth)) && (centery+indy>=SW_col_Low && centery+indy<=SW_col_High)
                                if (( centerx+indx<=FrameHeight)&&(centerx+indx+BlockSize-1>0 && centerx+indx+BlockSize-1<=FrameHeight)) && centerx+indx>=SW_row_Low && centerx+indx<=SW_row_High 

                                    Ref_Frame_Block = Ref_Frame_Y(centerx+indx:centerx+indx+BlockSize-1,centery+indy:centery+indy+BlockSize-1);
                                    Difference = (Current_Frame_Block - Ref_Frame_Block).^2;
                                    SSD_new = sum(sum(Difference(:)));
                                    if(SSD_new < minimumSSD)
                                        minimumSSD = SSD_new;
                                        Min_SSD_Index = [centerx+indx centery+indy];
                                    end
                                end
                            end
                        end
                    end
                end

                %% Motion Vector and Sub-Pel Check
                Motion_Vector(flag,:) = Min_SSD_Index-Current_Frame_Block_Index;
                %% Error Frame
                Error_i = i+Motion_Vector(flag,1);
                Error_j = j+Motion_Vector(flag,2);
                %% Sub-Pel Error Image
                Error_Frame_Y(i:i+BlockSize-1,j:j+BlockSize-1) = Current_Frame_Y(i:i+BlockSize-1,j:j+BlockSize-1) - Ref_Frame_Y(Error_i:Error_i+BlockSize-1,Error_j:Error_j+BlockSize-1);
                Error_Frame_Cb(i:i+BlockSize-1,j:j+BlockSize-1) = Current_Frame_Cb(i:i+BlockSize-1,j:j+BlockSize-1) - Ref_Frame_Cb(Error_i:Error_i+BlockSize-1,Error_j:Error_j+BlockSize-1);
                Error_Frame_Cr(i:i+BlockSize-1,j:j+BlockSize-1) = Current_Frame_Cr(i:i+BlockSize-1,j:j+BlockSize-1) - Ref_Frame_Cr(Error_i:Error_i+BlockSize-1,Error_j:Error_j+BlockSize-1);
            end
        end
end