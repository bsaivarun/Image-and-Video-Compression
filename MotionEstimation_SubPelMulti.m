function [Error_Frame_Y Error_Frame_Cb Error_Frame_Cr Motion_Vector MR] = MotionEstimation_SubPelMulti(Current_Frame_YCbCr,Ref_Frame,BlockSize,SearchRange,iframes,a,b)
    
    [FrameHeight FrameWidth FrameDim] = size(Current_Frame_YCbCr);
    Current_Frame_Y = Current_Frame_YCbCr(:,:,1);
    Current_Frame_Cb = Current_Frame_YCbCr(:,:,2);
    Current_Frame_Cr = Current_Frame_YCbCr(:,:,3);
    
    %% MultiFrame
    if (iframes >= 3)
        Ref_Frame_Y = Ref_Frame(:,1:FrameWidth,1);
        Ref_Frame_Y_2 = Ref_Frame(:,FrameWidth+1:end,1);
        Ref_Frame_Cb = Ref_Frame(:,1:FrameWidth,2);
        Ref_Frame_Cb_2 = Ref_Frame(:,FrameWidth+1:end,2);
        Ref_Frame_Cr = Ref_Frame(:,1:FrameWidth,3);
        Ref_Frame_Cr_2 = Ref_Frame(:,FrameWidth+1:end,3);
        
        Padd_Y = [Ref_Frame_Y Ref_Frame_Y(:,FrameWidth-1)];
        Padd_Y = [Padd_Y;Padd_Y(FrameHeight-1,:)];
        Padd_Cb = [Ref_Frame_Cb Ref_Frame_Cb(:,FrameWidth-1)];
        Padd_Cb = [Padd_Cb;Padd_Cb(FrameHeight-1,:)];
        Padd_Cr = [Ref_Frame_Cr Ref_Frame_Cr(:,FrameWidth-1)];
        Padd_Cr = [Padd_Cr;Padd_Cr(FrameHeight-1,:)];
        Padd_Y_2 = [Ref_Frame_Y_2 Ref_Frame_Y_2(:,FrameWidth-1)];
        Padd_Y_2 = [Padd_Y_2;Padd_Y_2(FrameHeight-1,:)];
        Padd_Cb_2 = [Ref_Frame_Cb_2 Ref_Frame_Cb_2(:,FrameWidth-1)];
        Padd_Cb_2 = [Padd_Cb_2;Padd_Cb_2(FrameHeight-1,:)];
        Padd_Cr_2 = [Ref_Frame_Cr_2 Ref_Frame_Cr_2(:,FrameWidth-1)];
        Padd_Cr_2 = [Padd_Cr_2;Padd_Cr_2(FrameHeight-1,:)];
        
        Ref_Frame_Y_SubPel = (1-b)*(1-a)*Padd_Y(1:FrameHeight,1:FrameWidth)+(1-b)*(a)*Padd_Y(1:FrameHeight,2:FrameWidth+1)+...
                             (b)*(1-a)*Padd_Y(2:FrameHeight+1,1:FrameWidth)+(b)*(a)*Padd_Y(2:FrameHeight+1,2:FrameWidth+1);
        Ref_Frame_Cb_SubPel = (1-b)*(1-a)*Padd_Cb(1:FrameHeight,1:FrameWidth)+(1-b)*(a)*Padd_Cb(1:FrameHeight,2:FrameWidth+1)+...
                              (b)*(1-a)*Padd_Cb(2:FrameHeight+1,1:FrameWidth)+(b)*(a)*Padd_Cb(2:FrameHeight+1,2:FrameWidth+1);
        Ref_Frame_Cr_SubPel = (1-b)*(1-a)*Padd_Cr(1:FrameHeight,1:FrameWidth)+(1-b)*(a)*Padd_Cr(1:FrameHeight,2:FrameWidth+1)+...
                              (b)*(1-a)*Padd_Cr(2:FrameHeight+1,1:FrameWidth)+(b)*(a)*Padd_Cr(2:FrameHeight+1,2:FrameWidth+1);                           
                           
        Ref_Frame_Y_2_SubPel = (1-b)*(1-a)*Padd_Y_2(1:FrameHeight,1:FrameWidth)+(1-b)*(a)*Padd_Y_2(1:FrameHeight,2:FrameWidth+1)+...
                               (b)*(1-a)*Padd_Y_2(2:FrameHeight+1,1:FrameWidth)+(b)*(a)*Padd_Y_2(2:FrameHeight+1,2:FrameWidth+1);
        Ref_Frame_Cb_2_SubPel = (1-b)*(1-a)*Padd_Cb_2(1:FrameHeight,1:FrameWidth)+(1-b)*(a)*Padd_Cb_2(1:FrameHeight,2:FrameWidth+1)+...
                                (b)*(1-a)*Padd_Cb_2(2:FrameHeight+1,1:FrameWidth)+(b)*(a)*Padd_Cb_2(2:FrameHeight+1,2:FrameWidth+1);
        Ref_Frame_Cr_2_SubPel = (1-b)*(1-a)*Padd_Cr_2(1:FrameHeight,1:FrameWidth)+(1-b)*(a)*Padd_Cr_2(1:FrameHeight,2:FrameWidth+1)+...
                                (b)*(1-a)*Padd_Cr_2(2:FrameHeight+1,1:FrameWidth)+(b)*(a)*Padd_Cr_2(2:FrameHeight+1,2:FrameWidth+1);

    else
        Ref_Frame_Y = Ref_Frame(:,:,1);
        Ref_Frame_Cb = Ref_Frame(:,:,2);
        Ref_Frame_Cr = Ref_Frame(:,:,3);
        Padd_Y = [Ref_Frame_Y Ref_Frame_Y(:,FrameWidth-1)];
        Padd_Y = [Padd_Y;Padd_Y(FrameHeight-1,:)];
        Padd_Cb = [Ref_Frame_Cb Ref_Frame_Cb(:,FrameWidth-1)];
        Padd_Cb = [Padd_Cb;Padd_Cb(FrameHeight-1,:)];
        Padd_Cr = [Ref_Frame_Cr Ref_Frame_Cr(:,FrameWidth-1)];
        Padd_Cr = [Padd_Cr;Padd_Cr(FrameHeight-1,:)];
        
        Ref_Frame_Y_SubPel = (1-b)*(1-a)*Padd_Y(1:FrameHeight,1:FrameWidth)+(1-b)*(a)*Padd_Y(1:FrameHeight,2:FrameWidth+1)+...
                             (b)*(1-a)*Padd_Y(2:FrameHeight+1,1:FrameWidth)+(b)*(a)*Padd_Y(2:FrameHeight+1,2:FrameWidth+1);
        Ref_Frame_Cb_SubPel = (1-b)*(1-a)*Padd_Cb(1:FrameHeight,1:FrameWidth)+(1-b)*(a)*Padd_Cb(1:FrameHeight,2:FrameWidth+1)+...
                              (b)*(1-a)*Padd_Cb(2:FrameHeight+1,1:FrameWidth)+(b)*(a)*Padd_Cb(2:FrameHeight+1,2:FrameWidth+1);
        Ref_Frame_Cr_SubPel = (1-b)*(1-a)*Padd_Cr(1:FrameHeight,1:FrameWidth)+(1-b)*(a)*Padd_Cr(1:FrameHeight,2:FrameWidth+1)+...
                              (b)*(1-a)*Padd_Cr(2:FrameHeight+1,1:FrameWidth)+(b)*(a)*Padd_Cr(2:FrameHeight+1,2:FrameWidth+1);

    end
    
    %% Motion Estimation
    Motion_Vector = [];
    flag = 0;
    loop = 0;
    for i = 1:BlockSize:FrameHeight-BlockSize+1
        for j = 1:BlockSize:FrameWidth-BlockSize+1
            flag = flag+1;
            %% Current Frame 8x8 Block
            Current_Frame_Block = Current_Frame_Y(i:i+BlockSize-1,j:j+BlockSize-1);
            Current_Frame_Block_Index = [i j];

            %% Previous Frame 8x8 Block
            Ref_Frame_Block = Ref_Frame_Y(i:i+BlockSize-1,j:j+BlockSize-1);
            if (iframes >= 3)
                Ref_Frame_Block_2 = Ref_Frame_Y_2(i:i+BlockSize-1,j:j+BlockSize-1);
            end

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
            if (iframes >= 3)
                SearchWindow_2 = Ref_Frame_Y_2(SW_row_Low:SW_row_High,SW_col_Low:SW_col_High);
            end

            %% Traverse
            SSD = inf;
            loop = 0;
            if (iframes >= 3)
                MR = 2;
            else 
                MR = 1;
            end
            for Multiple = 1 : MR
                row_traverse=SW_row_Low;
                if (Multiple == 1)
                    Search_Frame = Ref_Frame_Y;
                    Search_Frame_SubPel = Ref_Frame_Y_SubPel;
                else
                    Search_Frame = Ref_Frame_Y_2;
                    Search_Frame_SubPel = Ref_Frame_Y_2_SubPel;
                end                             
                while(row_traverse<=SW_row_High)
                    col_traverse=SW_col_Low;
                    while(col_traverse<=SW_col_High)
                        if((col_traverse <= FrameWidth-BlockSize+1+a) && (row_traverse <= FrameHeight-BlockSize+1+b))
                            loop = loop+1;
                            if ((mod(col_traverse,1) == a) && (mod(row_traverse,1) == b))
                                row_trav = floor(row_traverse);
                                col_trav = floor(col_traverse);
                                traverse_block = Search_Frame_SubPel(row_trav:row_trav+BlockSize-1,col_trav:col_trav+BlockSize-1);
                            elseif ((mod(col_traverse,1) == 0) && (mod(row_traverse,1) == 0))
                                traverse_block = Search_Frame(row_traverse:row_traverse+BlockSize-1,col_traverse:col_traverse+BlockSize-1);
                            else
                            end
                            Difference = (Current_Frame_Block - traverse_block).^2;
                            SSD_new = sum(sum(Difference(:)));
                            if(SSD_new < SSD)
                                SSD = SSD_new;
                                if (Multiple == 1)
                                    Ref_Frm = 1; 
                                else
                                    Ref_Frm = 2;
                                end
                                Min_SSD_Index = [row_traverse col_traverse];
                            end
                        end
                        col_traverse = col_traverse+a;
                    end
                    row_traverse = row_traverse+b;
                end
            end
            %% Motion Vector and Sub-Pel Check
            Motion_Vector(flag,:) = [Min_SSD_Index-Current_Frame_Block_Index Ref_Frm];

            %% Error Frame
            Error_i = i+Motion_Vector(flag,1);
            Error_j = j+Motion_Vector(flag,2);
            Error_Frm = Motion_Vector(flag,3);
            %% Sub-Pel Error Image

                if ((mod(Error_i,1) == a) || (mod(Error_j,1) == b))
                    Error_i = floor(Error_i);
                    Error_j = floor(Error_j);
                    if (Error_Frm == 1)
                        Error_Frame_Y(i:i+BlockSize-1,j:j+BlockSize-1) = Current_Frame_Y(i:i+BlockSize-1,j:j+BlockSize-1) - Ref_Frame_Y_SubPel(Error_i:Error_i+BlockSize-1,Error_j:Error_j+BlockSize-1);
                        Error_Frame_Cb(i:i+BlockSize-1,j:j+BlockSize-1) = Current_Frame_Cb(i:i+BlockSize-1,j:j+BlockSize-1) - Ref_Frame_Cb_SubPel(Error_i:Error_i+BlockSize-1,Error_j:Error_j+BlockSize-1);
                        Error_Frame_Cr(i:i+BlockSize-1,j:j+BlockSize-1) = Current_Frame_Cr(i:i+BlockSize-1,j:j+BlockSize-1) - Ref_Frame_Cr_SubPel(Error_i:Error_i+BlockSize-1,Error_j:Error_j+BlockSize-1);
                    elseif (Error_Frm == 2)
                        Error_Frame_Y(i:i+BlockSize-1,j:j+BlockSize-1) = Current_Frame_Y(i:i+BlockSize-1,j:j+BlockSize-1) - Ref_Frame_Y_2_SubPel(Error_i:Error_i+BlockSize-1,Error_j:Error_j+BlockSize-1);
                        Error_Frame_Cb(i:i+BlockSize-1,j:j+BlockSize-1) = Current_Frame_Cb(i:i+BlockSize-1,j:j+BlockSize-1) - Ref_Frame_Cb_2_SubPel(Error_i:Error_i+BlockSize-1,Error_j:Error_j+BlockSize-1);
                        Error_Frame_Cr(i:i+BlockSize-1,j:j+BlockSize-1) = Current_Frame_Cr(i:i+BlockSize-1,j:j+BlockSize-1) - Ref_Frame_Cr_2_SubPel(Error_i:Error_i+BlockSize-1,Error_j:Error_j+BlockSize-1);
                    end
                else
                    if (Error_Frm == 1)
                        Error_Frame_Y(i:i+BlockSize-1,j:j+BlockSize-1) = Current_Frame_Y(i:i+BlockSize-1,j:j+BlockSize-1) - Ref_Frame_Y(Error_i:Error_i+BlockSize-1,Error_j:Error_j+BlockSize-1);
                        Error_Frame_Cb(i:i+BlockSize-1,j:j+BlockSize-1) = Current_Frame_Cb(i:i+BlockSize-1,j:j+BlockSize-1) - Ref_Frame_Cb(Error_i:Error_i+BlockSize-1,Error_j:Error_j+BlockSize-1);
                        Error_Frame_Cr(i:i+BlockSize-1,j:j+BlockSize-1) = Current_Frame_Cr(i:i+BlockSize-1,j:j+BlockSize-1) - Ref_Frame_Cr(Error_i:Error_i+BlockSize-1,Error_j:Error_j+BlockSize-1);
                    elseif (Error_Frm == 2)
                        Error_Frame_Y(i:i+BlockSize-1,j:j+BlockSize-1) = Current_Frame_Y(i:i+BlockSize-1,j:j+BlockSize-1) - Ref_Frame_Y_2(Error_i:Error_i+BlockSize-1,Error_j:Error_j+BlockSize-1);
                        Error_Frame_Cb(i:i+BlockSize-1,j:j+BlockSize-1) = Current_Frame_Cb(i:i+BlockSize-1,j:j+BlockSize-1) - Ref_Frame_Cb_2(Error_i:Error_i+BlockSize-1,Error_j:Error_j+BlockSize-1);
                        Error_Frame_Cr(i:i+BlockSize-1,j:j+BlockSize-1) = Current_Frame_Cr(i:i+BlockSize-1,j:j+BlockSize-1) - Ref_Frame_Cr_2(Error_i:Error_i+BlockSize-1,Error_j:Error_j+BlockSize-1);
                    end
                end
        end
    end
end