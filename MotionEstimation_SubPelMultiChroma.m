function [Error_Frame_Y Error_Frame_Cb Error_Frame_Cr Motion_Vector MR] = MotionEstimation_SubPelMultiChroma(Current_Frame_YCbCr,Ref_Frame,BlockSize,SearchRange,iframes,a,b)
    
    [FrameHeight FrameWidth FrameDim] = size(Current_Frame_YCbCr);
    Current_Frame_Y = Current_Frame_YCbCr(:,:,1);
    Current_Frame_Cb = Current_Frame_YCbCr(:,:,2);
    Current_Frame_Cr = Current_Frame_YCbCr(:,:,3);
    %% Chroma Sub-Sampling
        Current_Frame_Cb = transpose(resample(transpose(resample(Current_Frame_Cb,1,2)),1,2));
        Current_Frame_Cr = transpose(resample(transpose(resample(Current_Frame_Cr,1,2)),1,2));
        
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
        Ref_Frame_Y_SubPel = (1-b)*(1-a)*Padd_Y(1:FrameHeight,1:FrameWidth)+(1-b)*(a)*Padd_Y(1:FrameHeight,2:FrameWidth+1)+...
                              (b)*(1-a)*Padd_Y(2:FrameHeight+1,1:FrameWidth)+(b)*(a)*Padd_Y(2:FrameHeight+1,2:FrameWidth+1);
        Ref_Frame_Cb = transpose(resample(transpose(resample(Ref_Frame_Cb,1,2)),1,2));
        Ref_Frame_Cr = transpose(resample(transpose(resample(Ref_Frame_Cr,1,2)),1,2));

        [SubHeight SubWidth SubDim] = size(Ref_Frame_Cb);

        Padd_Cb = [Ref_Frame_Cb Ref_Frame_Cb(:,SubWidth-1)];
        Padd_Cb = [Padd_Cb;Padd_Cb(SubHeight-1,:)];
        Padd_Cr = [Ref_Frame_Cr Ref_Frame_Cr(:,SubWidth-1)];
        Padd_Cr = [Padd_Cr;Padd_Cr(SubHeight-1,:)];
        Ref_Frame_Cb_SubPel = (1-b)*(1-a)*Padd_Cb(1:SubHeight,1:SubWidth)+(1-b)*(a)*Padd_Cb(1:SubHeight,2:SubWidth+1)+...
                               (b)*(1-a)*Padd_Cb(2:SubHeight+1,1:SubWidth)+(b)*(a)*Padd_Cb(2:SubHeight+1,2:SubWidth+1);
        Ref_Frame_Cr_SubPel = (1-b)*(1-a)*Padd_Cr(1:SubHeight,1:SubWidth)+(1-b)*(a)*Padd_Cr(1:SubHeight,2:SubWidth+1)+...
                               (b)*(1-a)*Padd_Cr(2:SubHeight+1,1:SubWidth)+(b)*(a)*Padd_Cr(2:SubHeight+1,2:SubWidth+1);

        Padd_Y_2 = [Ref_Frame_Y_2 Ref_Frame_Y_2(:,FrameWidth-1)];
        Padd_Y_2 = [Padd_Y_2;Padd_Y_2(FrameHeight-1,:)];
        Ref_Frame_Y_2_SubPel = (1-b)*(1-a)*Padd_Y_2(1:FrameHeight,1:FrameWidth)+(1-b)*(a)*Padd_Y_2(1:FrameHeight,2:FrameWidth+1)+...
                              (b)*(1-a)*Padd_Y_2(2:FrameHeight+1,1:FrameWidth)+(b)*(a)*Padd_Y_2(2:FrameHeight+1,2:FrameWidth+1);
        Ref_Frame_Cb_2 = transpose(resample(transpose(resample(Ref_Frame_Cb_2,1,2)),1,2));
        Ref_Frame_Cr_2 = transpose(resample(transpose(resample(Ref_Frame_Cr_2,1,2)),1,2));

        [SubHeight SubWidth SubDim] = size(Ref_Frame_Cb_2);

        Padd_Cb_2 = [Ref_Frame_Cb_2 Ref_Frame_Cb_2(:,SubWidth-1)];
        Padd_Cb_2 = [Padd_Cb_2;Padd_Cb_2(SubHeight-1,:)];
        Padd_Cr_2 = [Ref_Frame_Cr_2 Ref_Frame_Cr_2(:,SubWidth-1)];
        Padd_Cr_2 = [Padd_Cr_2;Padd_Cr_2(SubHeight-1,:)];
        Ref_Frame_Cb_2_SubPel = (1-b)*(1-a)*Padd_Cb_2(1:SubHeight,1:SubWidth)+(1-b)*(a)*Padd_Cb_2(1:SubHeight,2:SubWidth+1)+...
                               (b)*(1-a)*Padd_Cb_2(2:SubHeight+1,1:SubWidth)+(b)*(a)*Padd_Cb_2(2:SubHeight+1,2:SubWidth+1);
        Ref_Frame_Cr_2_SubPel = (1-b)*(1-a)*Padd_Cr_2(1:SubHeight,1:SubWidth)+(1-b)*(a)*Padd_Cr_2(1:SubHeight,2:SubWidth+1)+...
                               (b)*(1-a)*Padd_Cr_2(2:SubHeight+1,1:SubWidth)+(b)*(a)*Padd_Cr_2(2:SubHeight+1,2:SubWidth+1);

       
    else
        Ref_Frame_Y = Ref_Frame(:,:,1);
        Ref_Frame_Cb = Ref_Frame(:,:,2);
        Ref_Frame_Cr = Ref_Frame(:,:,3);
        
        Padd_Y = [Ref_Frame_Y Ref_Frame_Y(:,FrameWidth-1)];
        Padd_Y = [Padd_Y;Padd_Y(FrameHeight-1,:)];

        Ref_Frame_Y_SubPel = (1-b)*(1-a)*Padd_Y(1:FrameHeight,1:FrameWidth)+(1-b)*(a)*Padd_Y(1:FrameHeight,2:FrameWidth+1)+...
                              (b)*(1-a)*Padd_Y(2:FrameHeight+1,1:FrameWidth)+(b)*(a)*Padd_Y(2:FrameHeight+1,2:FrameWidth+1);

        Ref_Frame_Cb = transpose(resample(transpose(resample(Ref_Frame_Cb,1,2)),1,2));
        Ref_Frame_Cr = transpose(resample(transpose(resample(Ref_Frame_Cr,1,2)),1,2));
        [SubHeight SubWidth SubDim] = size(Ref_Frame_Cb);
        Padd_Cb = [Ref_Frame_Cb Ref_Frame_Cb(:,SubWidth-1)];
        Padd_Cb = [Padd_Cb;Padd_Cb(SubHeight-1,:)];
        Padd_Cr = [Ref_Frame_Cr Ref_Frame_Cr(:,SubWidth-1)];
        Padd_Cr = [Padd_Cr;Padd_Cr(SubHeight-1,:)];
        Ref_Frame_Cb_SubPel = (1-b)*(1-a)*Padd_Cb(1:SubHeight,1:SubWidth)+(1-b)*(a)*Padd_Cb(1:SubHeight,2:SubWidth+1)+...
                               (b)*(1-a)*Padd_Cb(2:SubHeight+1,1:SubWidth)+(b)*(a)*Padd_Cb(2:SubHeight+1,2:SubWidth+1);
        Ref_Frame_Cr_SubPel = (1-b)*(1-a)*Padd_Cr(1:SubHeight,1:SubWidth)+(1-b)*(a)*Padd_Cr(1:SubHeight,2:SubWidth+1)+...
                               (b)*(1-a)*Padd_Cr(2:SubHeight+1,1:SubWidth)+(b)*(a)*Padd_Cr(2:SubHeight+1,2:SubWidth+1);

    end
    
    %% Motion Estimation
    for k = 1:3
        if (k == 1)
            Current_Frame = Current_Frame_Y;
            RefFrame = Ref_Frame_Y;
            RefFrame_SubPel = Ref_Frame_Y_SubPel;
            if (iframes >= 3)
                RefFrame_2 = Ref_Frame_Y_2;
                RefFrame_2_SubPel = Ref_Frame_Y_2_SubPel;
            end
        elseif (k == 2)
            Current_Frame = Current_Frame_Cb;
            RefFrame = Ref_Frame_Cb;
            RefFrame_SubPel = Ref_Frame_Cb_SubPel;
            if (iframes >= 3)
                RefFrame_2 = Ref_Frame_Cb_2;
                RefFrame_2_SubPel = Ref_Frame_Cb_2_SubPel;
            end
        elseif (k == 3)
            Current_Frame = Current_Frame_Cr;
            RefFrame = Ref_Frame_Cr;
            RefFrame_SubPel = Ref_Frame_Cr_SubPel;
            if (iframes >= 3)
                RefFrame_2 = Ref_Frame_Cr_2;
                RefFrame_2_SubPel = Ref_Frame_Cr_2_SubPel;
            end
        end
        [Height Width Dim] = size(Current_Frame);
        Motion_Vector = [];
        flag = 0;
        loop = 0;
        for i = 1:BlockSize:Height-BlockSize+1
            for j = 1:BlockSize:Width-BlockSize+1
                flag = flag+1;
                %% Current Frame 8x8 Block
                Current_Frame_Block = Current_Frame(i:i+BlockSize-1,j:j+BlockSize-1);
                Current_Frame_Block_Index = [i j];

                %% Previous Frame 8x8 Block
                Ref_Frame_Block = RefFrame(i:i+BlockSize-1,j:j+BlockSize-1);
                if (iframes >= 3)
                    Ref_Frame_Block_2 = RefFrame_2(i:i+BlockSize-1,j:j+BlockSize-1);
                end

                %% +/- 4 pixels each size in previous frame
                SW_row_Low = i-SearchRange;
                SW_row_High = i+SearchRange;
                SW_col_Low = j-SearchRange;
                SW_col_High = j+SearchRange;
                if (SW_row_Low <= 1)
                    SW_row_Low = i;
                end
                if (SW_row_High >= Height)
                    SW_row_High = Height;
                end
                if (SW_col_Low <= 1)
                    SW_col_Low = j;
                end
                if (SW_col_High >= Width)
                    SW_col_High = Width;
                end
                SearchWindow = RefFrame(SW_row_Low:SW_row_High,SW_col_Low:SW_col_High);
                if (iframes >= 3)
                    SearchWindow_2 = RefFrame_2(SW_row_Low:SW_row_High,SW_col_Low:SW_col_High);
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
                    if (Multiple == 1)
                        row_traverse=SW_row_Low;
                        Search_Frame = RefFrame;
                        Search_Frame_SubPel = RefFrame_SubPel;
                    else
                        row_traverse=SW_row_Low;
                        Search_Frame = RefFrame_2;
                        Search_Frame_SubPel = RefFrame_2_SubPel;
                    end                             
                    while(row_traverse<=SW_row_High)
                        col_traverse=SW_col_Low;
                        while(col_traverse<=SW_col_High)
                            if((col_traverse <= Width-BlockSize+1+a) && (row_traverse <= Height-BlockSize+1+b))
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
                    
                if (k == 1)
                    if ((mod(Error_i,1) == a) || (mod(Error_j,1) == b))
                        Error_i = floor(Error_i);
                        Error_j = floor(Error_j);
                        if (Error_Frm == 1)
                            Error_Frame_Y(i:i+BlockSize-1,j:j+BlockSize-1) = Current_Frame(i:i+BlockSize-1,j:j+BlockSize-1) - RefFrame_SubPel(Error_i:Error_i+BlockSize-1,Error_j:Error_j+BlockSize-1);
                        elseif (Error_Frm == 2)
                            Error_Frame_Y(i:i+BlockSize-1,j:j+BlockSize-1) = Current_Frame(i:i+BlockSize-1,j:j+BlockSize-1) - RefFrame_2_SubPel(Error_i:Error_i+BlockSize-1,Error_j:Error_j+BlockSize-1);
                        end
                    else
                        if (Error_Frm == 1)
                            Error_Frame_Y(i:i+BlockSize-1,j:j+BlockSize-1) = Current_Frame(i:i+BlockSize-1,j:j+BlockSize-1) - RefFrame(Error_i:Error_i+BlockSize-1,Error_j:Error_j+BlockSize-1);
                        elseif (Error_Frm == 2)
                            Error_Frame_Y(i:i+BlockSize-1,j:j+BlockSize-1) = Current_Frame(i:i+BlockSize-1,j:j+BlockSize-1) - RefFrame_2(Error_i:Error_i+BlockSize-1,Error_j:Error_j+BlockSize-1);
                        end
                    end
                    Motion_Vector_Y = Motion_Vector;
                elseif (k == 2)
                    if ((mod(Error_i,1) == a) || (mod(Error_j,1) == b))
                        if (Error_Frm == 1)
                            Error_i = floor(Error_i);
                            Error_j = floor(Error_j);
                            Error_Frame_Cb(i:i+BlockSize-1,j:j+BlockSize-1) = Current_Frame(i:i+BlockSize-1,j:j+BlockSize-1) - RefFrame_SubPel(Error_i:Error_i+BlockSize-1,Error_j:Error_j+BlockSize-1);
                        elseif (Error_Frm == 2)
                            Error_i = floor(Error_i);
                            Error_j = floor(Error_j);
                            Error_Frame_Cb(i:i+BlockSize-1,j:j+BlockSize-1) = Current_Frame(i:i+BlockSize-1,j:j+BlockSize-1) - RefFrame_2_SubPel(Error_i:Error_i+BlockSize-1,Error_j:Error_j+BlockSize-1);
                        end
                    else
                        if (Error_Frm == 1)
                            Error_Frame_Cb(i:i+BlockSize-1,j:j+BlockSize-1) = Current_Frame(i:i+BlockSize-1,j:j+BlockSize-1) - RefFrame(Error_i:Error_i+BlockSize-1,Error_j:Error_j+BlockSize-1);
                        elseif (Error_Frm == 2)
                            Error_Frame_Cb(i:i+BlockSize-1,j:j+BlockSize-1) = Current_Frame(i:i+BlockSize-1,j:j+BlockSize-1) - RefFrame_2(Error_i:Error_i+BlockSize-1,Error_j:Error_j+BlockSize-1);
                        end
                    end
                    Motion_Vector_Cb = Motion_Vector;
                elseif(k == 3)
                    if ((mod(Error_i,1) == a) || (mod(Error_j,1) == b))
                        if (Error_Frm == 1)
                            Error_i = floor(Error_i);
                            Error_j = floor(Error_j);
                            Error_Frame_Cr(i:i+BlockSize-1,j:j+BlockSize-1) = Current_Frame(i:i+BlockSize-1,j:j+BlockSize-1) - RefFrame_SubPel(Error_i:Error_i+BlockSize-1,Error_j:Error_j+BlockSize-1);
                        elseif (Error_Frm == 2)
                            Error_i = floor(Error_i);
                            Error_j = floor(Error_j);
                            Error_Frame_Cr(i:i+BlockSize-1,j:j+BlockSize-1) = Current_Frame(i:i+BlockSize-1,j:j+BlockSize-1) - RefFrame_2_SubPel(Error_i:Error_i+BlockSize-1,Error_j:Error_j+BlockSize-1);
                        end
                    else
                        if (Error_Frm == 1)
                            Error_Frame_Cr(i:i+BlockSize-1,j:j+BlockSize-1) = Current_Frame(i:i+BlockSize-1,j:j+BlockSize-1) - RefFrame(Error_i:Error_i+BlockSize-1,Error_j:Error_j+BlockSize-1);
                        elseif (Error_Frm == 2)
                            Error_Frame_Cr(i:i+BlockSize-1,j:j+BlockSize-1) = Current_Frame(i:i+BlockSize-1,j:j+BlockSize-1) - RefFrame_2(Error_i:Error_i+BlockSize-1,Error_j:Error_j+BlockSize-1);
                        end
                    end
                    Motion_Vector_Cr = Motion_Vector;
                end
            end
        end
    end
    Motion_Vector = [Motion_Vector_Y;Motion_Vector_Cb;Motion_Vector_Cr];
end