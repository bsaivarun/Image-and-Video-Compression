clear all
% close all
% clc
Scaling_Factors = [5 3 1 .5 .4 .35 .3 .25 .2 .18];
Scaling_Factors = [1];
SearchRange = 4;
BlockSize = 8;
run = 1;
SADCalcs = 0;

while run <= numel(Scaling_Factors)
    fprintf('------ Current Run = %d ------\n',run);
    Scaling_Factor = Scaling_Factors(run);
    fprintf('------ Scaling_Factor = %f ------\n',Scaling_Factor);

    %% Training Data
    fprintf('------ Training the Huffman Table ------\n');
    SmallFrame = double(imread('data/Images/lena_small.tif'));
    [SmallFrameHeight SmallFrameWidth SmallFrameDim] = size(SmallFrame);
    [SmallImage_YCbCr(:,:,1) SmallImage_YCbCr(:,:,2) SmallImage_YCbCr(:,:,3)] = ictRGB2YCbCr(SmallFrame(:,:,1), SmallFrame(:,:,2), SmallFrame(:,:,3));
    RLEnc_Small = IntraEncode_YCbCr(SmallImage_YCbCr,Scaling_Factor);

    %% Building Huffman Code
    Lower = -700;
    FrameHist = hist(RLEnc_Small(:),Lower:700);
    PMF = FrameHist/sum(FrameHist);
    [BinaryTree, HuffCode, BinCode, Codelengths] = buildHuffman(PMF);
    fprintf('------ Huffman Table Training Complete ------\n');
    fprintf('------ Motion Compensation Starting ------\n');

    %% Motion Estimation and Motion Compensation
    for iframes = 1:21
        Fr_Num = iframes+19;
        fprintf('------ Decoding Frame - %d ------\n',iframes);
        
        %% First Frame for DCT - Based Still Frame Coding
        if (iframes == 1)
            FirstFrame = double(imread('data/sequences/foreman20_40_RGB/foreman0020.bmp'));
            [FrameHeight FrameWidth FrameDim] = size(FirstFrame);
            [FirstFrame_YCbCr(:,:,1) FirstFrame_YCbCr(:,:,2) FirstFrame_YCbCr(:,:,3)] = ictRGB2YCbCr(FirstFrame(:,:,1),FirstFrame(:,:,2), FirstFrame(:,:,3));

            %% Zero Run Length Encoding
            FirstFrame_zeroRun = IntraEncode_YCbCr(FirstFrame_YCbCr,Scaling_Factor);
            
            %% Huffman Encoding & Decoding
            bytestream = enc_huffman_new(FirstFrame_zeroRun-Lower+1, BinCode, Codelengths);
%             Bitrate_Frame = length(bytestream)*8 / (FrameWidth * FrameHeight);
            Reconstructed_Data = double(reshape(dec_huffman_new(bytestream,BinaryTree,max(size(FirstFrame_zeroRun(:)))),size(FirstFrame_zeroRun)))+Lower-1;

            %% Decoding the Frame Blockwise in YCbCr
            [Decoded_Ref_Frame_Y Decoded_Ref_Frame_Cb Decoded_Ref_Frame_Cr] = IntraDecode(Reconstructed_Data,FirstFrame,Scaling_Factor);
            Decoded_Frames_Y(:,1:FrameWidth) = Decoded_Ref_Frame_Y;
            Decoded_Frames_Cb(:,1:FrameWidth) = Decoded_Ref_Frame_Cb;
            Decoded_Frames_Cr(:,1:FrameWidth) = Decoded_Ref_Frame_Cr;

            %% YCbCr to RGB
            [FirstDecodedFrame(:,:,1) FirstDecodedFrame(:,:,2) FirstDecodedFrame(:,:,3)] = ictYCbCr2RGB(Decoded_Ref_Frame_Y,Decoded_Ref_Frame_Cb,Decoded_Ref_Frame_Cr);
    %         figure('Name','Decoded - foreman0020.bmp')
    %         imshow(FirstDecodedFrame/256);

            %% Required Outputs
            [Bitrate_Frame,MSE,PSNR] = DistortionOutputs(FirstFrame,FirstDecodedFrame,FrameHeight,FrameWidth,FrameDim,8,bytestream);
            Bitrate_Frames(:,1) = Bitrate_Frame;
            Bitrate_Total(:,1) = Bitrate_Frame;
            PSNR_Frames(:,1) = PSNR;
            fprintf('------ Frame - %d - Decoded ------\n',iframes);
        
        %% Remaining Frames ME and MCP
        else
            %% Color Transform of all Frames
            Frame_FileName = strcat('data/sequences/foreman20_40_RGB/foreman00',num2str(Fr_Num),'.bmp');
            CurrentFrame = double(imread(Frame_FileName));
            [Y_Frame Cb_Frame Cr_Frame] = ictRGB2YCbCr(CurrentFrame(:,:,1),CurrentFrame(:,:,2), CurrentFrame(:,:,3));
            Y_frames(:,(iframes-1)*FrameWidth+1:iframes*FrameWidth) = Y_Frame;
            Cb_frames(:,(iframes-1)*FrameWidth+1:iframes*FrameWidth) = Cb_Frame;
            Cr_frames(:,(iframes-1)*FrameWidth+1:iframes*FrameWidth) = Cr_Frame;

            %% Current Frame to be Decoded
            Current_Frame_Y = Y_frames(:,(iframes-1)*FrameWidth+1:iframes*FrameWidth);
            Current_Frame_Cb = Cb_frames(:,(iframes-1)*FrameWidth+1:iframes*FrameWidth);
            Current_Frame_Cr = Cr_frames(:,(iframes-1)*FrameWidth+1:iframes*FrameWidth);
            Current_Frame_YCbCr(:,:,1) = Current_Frame_Y;
            Current_Frame_YCbCr(:,:,2) = Current_Frame_Cb;
            Current_Frame_YCbCr(:,:,3) = Current_Frame_Cr;        

            %% Reference frame (Previous Decoded Frame)
            Ref_Frame_Y = Decoded_Frames_Y(:,(iframes-2)*FrameWidth+1:(iframes-1)*FrameWidth);
            Ref_Frame_Cb = Decoded_Frames_Cb(:,(iframes-2)*FrameWidth+1:(iframes-1)*FrameWidth);
            Ref_Frame_Cr = Decoded_Frames_Cr(:,(iframes-2)*FrameWidth+1:(iframes-1)*FrameWidth);
            Ref_Frame(:,:,1) = Ref_Frame_Y;
            Ref_Frame(:,:,2) = Ref_Frame_Cb;
            Ref_Frame(:,:,3) = Ref_Frame_Cr;

            %% Motion Estimation
            flag = 0;
            loop = 0;
            Motion_Vector = zeros(FrameHeight*FrameWidth/BlockSize^2,2);
            for i = 1:BlockSize:FrameHeight-BlockSize+1
                for j = 1:BlockSize:FrameWidth-BlockSize+1
                    flag = flag+1;
                    %% Current Frame 8x8 Block
                    Current_Frame_Block = Current_Frame_Y(i:i+BlockSize-1,j:j+BlockSize-1);
                    Current_Frame_Block_Index = [i j];
                    Current_Frame_Block_Sum = sum(sum(Current_Frame_Block(:)));

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

                    %% Traverse
                    SSD = inf;
                    row_traverse=SW_row_Low;
                    loop = 0;
                    traverse_block_Sum = [];
                    while(row_traverse<=SW_row_High)
                        col_traverse=SW_col_Low;
                        while(col_traverse<=SW_col_High)
                            if((col_traverse <= FrameWidth-BlockSize+1) && (row_traverse <= FrameHeight-BlockSize+1))
                                loop = loop+1;
                                traverse_block = Ref_Frame_Y(row_traverse:row_traverse+BlockSize-1,col_traverse:col_traverse+BlockSize-1);
                                Traverse_Block_Sum = sum(sum(traverse_block(:)));
                                traverse_block_Sum(loop,:) = [row_traverse-i col_traverse-j Traverse_Block_Sum (Current_Frame_Block_Sum - Traverse_Block_Sum)^2/(BlockSize^2)];
                                if((row_traverse-i == 0) && (col_traverse-j == 0))
%                                     Difference = (Current_Frame_Block - traverse_block).^2;
%                                     SSD_Calc = sum(sum(Difference(:)));
                                    SSD_Calc = sum(sum((Current_Frame_Block - traverse_block).^2));
                                    Min_SSD_Index_Prev = [0 0]+Current_Frame_Block_Index;
                                    SADCalcs = SADCalcs+1;
                                end
                            end
                        col_traverse = col_traverse+1;
                        end
                        row_traverse = row_traverse+1;
                    end
                    Min_SSD = SSD_Calc;
                    Remaining_Calc = traverse_block_Sum(:,4);
                    while(numel(Remaining_Calc) > 1)
                        Index = [];
                        Remaining_Calcs = [];
%                         Check = (Remaining_Calc <= Min_SSD);
                        Index = find(Remaining_Calc <= Min_SSD);
                        Remaining_Calcs(1:numel(Index),1) = Remaining_Calc(Index(1:end));
                        Remaining_Calc = Remaining_Calcs;
                        Min_SSD_Position = find(traverse_block_Sum(:,4) == min(Remaining_Calc));
                        if numel(Min_SSD_Position) > 1
                            Min_SSD_Index = Min_SSD_Index_Prev;
                        else
                            Min_SSD_Index = [traverse_block_Sum(Min_SSD_Position,1) traverse_block_Sum(Min_SSD_Position,2)]+Current_Frame_Block_Index;
                        end
                        if (Min_SSD_Index == Min_SSD_Index_Prev)
                            Remaining_Calc = 1;
                        else
                            if (Min_SSD_Index(2)+BlockSize <= FrameWidth) && (Min_SSD_Index(1)+BlockSize <= FrameHeight)
                                Min_SSD_Traverse = Ref_Frame_Y(Min_SSD_Index(1):Min_SSD_Index(1)+BlockSize-1,Min_SSD_Index(2):Min_SSD_Index(2)+BlockSize-1);
                                Min_SSD_Index_Prev = Min_SSD_Index;
                                Min_SSD = sum(sum((Current_Frame_Block - Min_SSD_Traverse).^2));
                                SADCalcs = SADCalcs+1;
                            else
                                Min_SSD_Index = Min_SSD_Index_Prev;
                                Remaining_Calc = 1;
                            end
                        end
                    end
                    
                    %% Motion Vector
                    Motion_Vector(flag,:) = Min_SSD_Index-Current_Frame_Block_Index;

                    %% Error Frame
                    Error_i = i+Motion_Vector(flag,1);
                    Error_j = j+Motion_Vector(flag,2);
                    %% Sub-Pel Error Image
                    if((mod(Error_i,1) ~=0) || (mod(Error_j,1) ~=0))
                        Error_i = floor(Error_i);
                        Error_j = floor(Error_j);
                        Error_Frame_Y(i:i+BlockSize-1,j:j+BlockSize-1) = Current_Frame_Y(i:i+BlockSize-1,j:j+BlockSize-1) - Ref_Frame_Y_Sub_Pel(Error_i:Error_i+BlockSize-1,Error_j:Error_j+BlockSize-1);
                        Error_Frame_Cb(i:i+BlockSize-1,j:j+BlockSize-1) = Current_Frame_Cb(i:i+BlockSize-1,j:j+BlockSize-1) - Ref_Frame_Cb_Sub_Pel(Error_i:Error_i+BlockSize-1,Error_j:Error_j+BlockSize-1);
                        Error_Frame_Cr(i:i+BlockSize-1,j:j+BlockSize-1) = Current_Frame_Cr(i:i+BlockSize-1,j:j+BlockSize-1) - Ref_Frame_Cr_Sub_Pel(Error_i:Error_i+BlockSize-1,Error_j:Error_j+BlockSize-1);
                    else
                        Error_Frame_Y(i:i+BlockSize-1,j:j+BlockSize-1) = Current_Frame_Y(i:i+BlockSize-1,j:j+BlockSize-1) - Ref_Frame_Y(Error_i:Error_i+BlockSize-1,Error_j:Error_j+BlockSize-1);
                        Error_Frame_Cb(i:i+BlockSize-1,j:j+BlockSize-1) = Current_Frame_Cb(i:i+BlockSize-1,j:j+BlockSize-1) - Ref_Frame_Cb(Error_i:Error_i+BlockSize-1,Error_j:Error_j+BlockSize-1);
                        Error_Frame_Cr(i:i+BlockSize-1,j:j+BlockSize-1) = Current_Frame_Cr(i:i+BlockSize-1,j:j+BlockSize-1) - Ref_Frame_Cr(Error_i:Error_i+BlockSize-1,Error_j:Error_j+BlockSize-1);
                    end
                end
            end
            Error_Frame(:,:,1) = Error_Frame_Y;
            Error_Frame(:,:,2) = Error_Frame_Cb;
            Error_Frame(:,:,3) = Error_Frame_Cr;


            %% Zero Run Length Encoding
            zeroRun = IntraEncode_YCbCr(Error_Frame,Scaling_Factor);

            %% Building Huffman Code for MV
            if ( iframes == 2)
                Lower_MV = -SearchRange-1;
                ImageHist_MV = hist(Motion_Vector(:),Lower_MV:max(Motion_Vector(:)));
                PMF_MV = ImageHist_MV/sum(ImageHist_MV);
                [BinaryTree_MV, HuffCode_MV, BinCode_MV, Codelengths_MV] = buildHuffman(PMF_MV);

            %% Building Huffman Code for Error Image
                Lower_ZR = -700;
                ImageHist_ZR = hist(zeroRun(:),Lower_ZR:700);
                PMF_ZR = ImageHist_ZR/sum(ImageHist_ZR);
                [BinaryTree_ZR, HuffCode_ZR, BinCode_ZR, Codelengths_ZR] = buildHuffman(PMF_ZR);
            end
            %% Huffman Encoding
            bytestream_Frame = enc_huffman_new(zeroRun-Lower_ZR+1, BinCode_ZR, Codelengths_ZR);
            bytestream_MV = enc_huffman_new(floor(Motion_Vector-Lower_MV+1), BinCode_MV, Codelengths_MV);

            %% Motion Compensation (Decoding the current Frame)
            Decoded_Ref_Frame = IntraDecode_YCbCr(zeroRun,Motion_Vector,Ref_Frame,Scaling_Factor);
            Decoded_Ref_Frame_Y = Decoded_Ref_Frame(:,:,1);
            Decoded_Ref_Frame_Cb = Decoded_Ref_Frame(:,:,2);
            Decoded_Ref_Frame_Cr = Decoded_Ref_Frame(:,:,3);
            Decoded_Frames_Y(:,(iframes-1)*FrameWidth+1:iframes*FrameWidth) = Decoded_Ref_Frame_Y;
            Decoded_Frames_Cb(:,(iframes-1)*FrameWidth+1:iframes*FrameWidth) = Decoded_Ref_Frame_Cb;
            Decoded_Frames_Cr(:,(iframes-1)*FrameWidth+1:iframes*FrameWidth) = Decoded_Ref_Frame_Cr;

            %% YCbCr to RGB
            [Decoded_Frame(:,:,1) Decoded_Frame(:,:,2) Decoded_Frame(:,:,3)] = ictYCbCr2RGB(Decoded_Ref_Frame_Y,Decoded_Ref_Frame_Cb,Decoded_Ref_Frame_Cr);
    %         figure('Name',strcat('Decoded - foreman00',num2str(i),'.bmp'))
    %         imshow(Decoded_Frame/256);

            %% Decoded frames in RGB
            Decoded_Frames_R(:,(iframes-1)*FrameWidth+1:iframes*FrameWidth) = Decoded_Frame(:,:,1);
            Decoded_Frames_G(:,(iframes-1)*FrameWidth+1:iframes*FrameWidth) = Decoded_Frame(:,:,2);
            Decoded_Frames_B(:,(iframes-1)*FrameWidth+1:iframes*FrameWidth) = Decoded_Frame(:,:,3);

            %% BitRate,MSE & PSNR Calculation
            [Bitrate_Frame,MSE,PSNR] = DistortionOutputs(CurrentFrame,Decoded_Frame,FrameHeight,FrameWidth,FrameDim,8,bytestream_Frame);
            PSNR_Frames(:,iframes) = PSNR;
            Bitrate_MV = length(bytestream_MV)*8 / (FrameWidth * FrameHeight);
            Bitrate_Frames(:,iframes) = Bitrate_Frame;
            Bitrate_MVs(:,iframes) = Bitrate_MV;
            Bitrate_Total(:,iframes) = Bitrate_Frame + Bitrate_MV;
            
        fprintf('------ Frame - %d - Decoded ------\n',iframes);
        end 
    end

    %% Required Outputs
    Final_rate = mean(Bitrate_Total)
    Final_PSNR = mean(PSNR_Frames)

    Bitrate_all(run) = mean(Final_rate);
    PSNR_all(run) = Final_PSNR;
    run = run+1;
end
%% R-D Plot
Bitrate_PSNR = vertcat(Bitrate_all,PSNR_all)
plot(Bitrate_all,PSNR_all);
hold on;
