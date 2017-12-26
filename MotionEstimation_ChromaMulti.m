function [Error_Frame_Y Error_Frame_Cb Error_Frame_Cr Motion_Vector MR] = MotionEstimation_ChromaMulti(Current_Frame_YCbCr,Ref_Frame,BlockSize,SearchRange,iframes)

[FrameHeight FrameWidth FrameDim] = size(Ref_Frame);
Current_Frame_Y = Current_Frame_YCbCr(:,:,1);
Current_Frame_Cb = Current_Frame_YCbCr(:,:,2);
Current_Frame_Cr = Current_Frame_YCbCr(:,:,3);

Ref_Frame_Y = Ref_Frame(:,:,1);
Ref_Frame_Cb = Ref_Frame(:,:,2);
Ref_Frame_Cr = Ref_Frame(:,:,3);
if (iframes >= 3)
    FrameWidth = FrameWidth/2;
    Ref_Frame_Y = Ref_Frame(:,1:FrameWidth,1);
    Ref_Frame_Y_2 = Ref_Frame(:,FrameWidth+1:end,1);
    Ref_Frame_Cb = Ref_Frame(:,1:FrameWidth,2);
    Ref_Frame_Cb_2 = Ref_Frame(:,FrameWidth+1:end,2);
    Ref_Frame_Cr = Ref_Frame(:,1:FrameWidth,3);
    Ref_Frame_Cr_2 = Ref_Frame(:,FrameWidth+1:end,3);
    Ref_Frame_Cb_2 = transpose(resample(transpose(resample(Ref_Frame_Cb_2,1,2)),1,2));
    Ref_Frame_Cr_2 = transpose(resample(transpose(resample(Ref_Frame_Cr_2,1,2)),1,2));
else        
    Ref_Frame_Cb = transpose(resample(transpose(resample(Ref_Frame_Cb,1,2)),1,2));
    Ref_Frame_Cr = transpose(resample(transpose(resample(Ref_Frame_Cr,1,2)),1,2));
end
%% Chroma Sub-Sampling
Current_Frame_Cb = transpose(resample(transpose(resample(Current_Frame_Cb,1,2)),1,2));
Current_Frame_Cr = transpose(resample(transpose(resample(Current_Frame_Cr,1,2)),1,2));

%% Motion Estimation

for k = 1:3
    if (k == 1)
        Current_Frame = Current_Frame_Y;
        RefFrame = Ref_Frame_Y;
        if (iframes >= 3)
            RefFrame_2= Ref_Frame_Y_2;
        end
    elseif (k == 2)
        Current_Frame = Current_Frame_Cb;
        RefFrame = Ref_Frame_Cb;
        if (iframes >= 3)
            RefFrame_2= Ref_Frame_Cb_2;
        end
    elseif (k == 3)
        Current_Frame = Current_Frame_Cr;
        RefFrame = Ref_Frame_Cr;
        if (iframes >= 3)
            RefFrame_2= Ref_Frame_Cr_2;
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
            row_traverse=SW_row_Low;
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
                else
                    row_traverse=SW_row_Low;
                    Search_Frame = RefFrame_2;
                end
                while(row_traverse<=SW_row_High)
                    col_traverse=SW_col_Low;
                    while(col_traverse<=SW_col_High)
                        if((col_traverse <= Width-BlockSize+1) && (row_traverse <= Height-BlockSize+1))
                            loop = loop+1;
                            traverse_block = Search_Frame(row_traverse:row_traverse+BlockSize-1,col_traverse:col_traverse+BlockSize-1);
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
                        col_traverse = col_traverse+1;
                    end
                    row_traverse = row_traverse+1;
                end
            end
            %% Motion Vector
            Motion_Vector(flag,:) = [Min_SSD_Index-Current_Frame_Block_Index , Ref_Frm];
            
            %% Error Frame
            Error_i = i+Motion_Vector(flag,1);
            Error_j = j+Motion_Vector(flag,2);
            Error_Frm = Motion_Vector(flag,3);
            %% Error Image
            if (Error_Frm == 1)
                if (k == 1)
                    Error_Frame_Y(i:i+BlockSize-1,j:j+BlockSize-1) = Current_Frame(i:i+BlockSize-1,j:j+BlockSize-1) - RefFrame(Error_i:Error_i+BlockSize-1,Error_j:Error_j+BlockSize-1);
                    Motion_Vector_Y = Motion_Vector;
                elseif (k == 2)
                    Error_Frame_Cb(i:i+BlockSize-1,j:j+BlockSize-1) = Current_Frame(i:i+BlockSize-1,j:j+BlockSize-1) - RefFrame(Error_i:Error_i+BlockSize-1,Error_j:Error_j+BlockSize-1);
                    Motion_Vector_Cb = Motion_Vector;
                elseif (k == 3)
                    Error_Frame_Cr(i:i+BlockSize-1,j:j+BlockSize-1) = Current_Frame(i:i+BlockSize-1,j:j+BlockSize-1) - RefFrame(Error_i:Error_i+BlockSize-1,Error_j:Error_j+BlockSize-1);
                    Motion_Vector_Cr = Motion_Vector;
                end
            else
                if (k == 1)
                    Error_Frame_Y(i:i+BlockSize-1,j:j+BlockSize-1) = Current_Frame(i:i+BlockSize-1,j:j+BlockSize-1) - RefFrame_2(Error_i:Error_i+BlockSize-1,Error_j:Error_j+BlockSize-1);
                    Motion_Vector_Y = Motion_Vector;
                elseif (k == 2)
                    Error_Frame_Cb(i:i+BlockSize-1,j:j+BlockSize-1) = Current_Frame(i:i+BlockSize-1,j:j+BlockSize-1) - RefFrame_2(Error_i:Error_i+BlockSize-1,Error_j:Error_j+BlockSize-1);
                    Motion_Vector_Cb = Motion_Vector;
                elseif (k == 3)
                    Error_Frame_Cr(i:i+BlockSize-1,j:j+BlockSize-1) = Current_Frame(i:i+BlockSize-1,j:j+BlockSize-1) - RefFrame_2(Error_i:Error_i+BlockSize-1,Error_j:Error_j+BlockSize-1);
                    Motion_Vector_Cr = Motion_Vector;
                end
            end
            
        end
    end
end
Motion_Vector = [Motion_Vector_Y;Motion_Vector_Cb;Motion_Vector_Cr];
end