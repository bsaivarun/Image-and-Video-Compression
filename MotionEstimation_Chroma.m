function [Error_Frame_Y Error_Frame_Cb Error_Frame_Cr Motion_Vector] = MotionEstimation_Chroma(Current_Frame_YCbCr,Ref_Frame,BlockSize,SearchRange)        

        [FrameHeight FrameWidth FrameDim] = size(Ref_Frame);
        Current_Frame_Y = Current_Frame_YCbCr(:,:,1);
        Current_Frame_Cb = Current_Frame_YCbCr(:,:,2);
        Current_Frame_Cr = Current_Frame_YCbCr(:,:,3);
        Ref_Frame_Y = Ref_Frame(:,:,1);
        Ref_Frame_Cb = Ref_Frame(:,:,2);
        Ref_Frame_Cr = Ref_Frame(:,:,3);

        %% Chroma Sub-Sampling
        Current_Frame_Cb = transpose(resample(transpose(resample(Current_Frame_Cb,1,2)),1,2));
        Current_Frame_Cr = transpose(resample(transpose(resample(Current_Frame_Cr,1,2)),1,2));
        Ref_Frame_Cb = transpose(resample(transpose(resample(Ref_Frame_Cb,1,2)),1,2));
        Ref_Frame_Cr = transpose(resample(transpose(resample(Ref_Frame_Cr,1,2)),1,2));

        %% Motion Estimation

        for k = 1:3
            if (k == 1)
               Current_Frame = Current_Frame_Y;
               RefFrame = Ref_Frame_Y;
            elseif (k == 2)
               Current_Frame = Current_Frame_Cb;
               RefFrame = Ref_Frame_Cb;
            elseif (k == 3)
               Current_Frame = Current_Frame_Cr;
               RefFrame = Ref_Frame_Cr;
            end
               [Height Width Dim] = size(Current_Frame);
               Motion_Vector = zeros(Height*Width/BlockSize^2,2);
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

                    %% Traverse
                    SSD = inf;
                    row_traverse=SW_row_Low;
                    loop = 0;
                    while(row_traverse<=SW_row_High)
                        col_traverse=SW_col_Low;
                        while(col_traverse<=SW_col_High)
                            if((col_traverse <= Width-BlockSize+1) && (row_traverse <= Height-BlockSize+1))
                                loop = loop+1;
                                traverse_block = RefFrame(row_traverse:row_traverse+BlockSize-1,col_traverse:col_traverse+BlockSize-1);
                                Difference = (Current_Frame_Block - traverse_block).^2;
                                SSD_new = sum(sum(Difference(:)));
                                if(SSD_new < SSD)
                                    SSD = SSD_new;
                                    Min_SSD_Index = [row_traverse col_traverse];
                                end
                            end
                        col_traverse = col_traverse+1;
                        end
                        row_traverse = row_traverse+1;
                    end
                    %% Motion Vector
                    Motion_Vector(flag,:) = Min_SSD_Index-Current_Frame_Block_Index;

                    %% Error Frame
                    Error_i = i+Motion_Vector(flag,1);
                    Error_j = j+Motion_Vector(flag,2);
                    %% Error Image
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

                end
            end
        end
        Motion_Vector = [Motion_Vector_Y;Motion_Vector_Cb;Motion_Vector_Cr];
end