clear all
Scaling_Factors = [5 3 1 .5 .4 .35 .3 .25 .2 .18];
% Scaling_Factors = [ 1 .3];
Scaling_Factors = 1;
SearchRange = 4;
BlockSize = 8;
run = 1;

fprintf('\t1. Full Block Search\n');
fprintf('\t2. 2-D Logarithmic Search\n');
SearchType = input('\nWhich type of Search you need to Implement?\n');
    if SearchType == 1
        BlockSearch = string('FullBlockSearch');
        fprintf('\t1. No Optimization\n');
        fprintf('\t2. Half-Pel Partial\n');
        fprintf('\t3. Half-Pel Complete\n');
        fprintf('\t4. Quarter-Pel Partial\n');
        fprintf('\t5. Quarter-Pel Complete\n');
        fprintf('\t6. Multiple Reference Frames\n');
        fprintf('\t7. Chroma SubSampling\n');
        fprintf('\t8. Half-Pel + Chroma SubSampling\n');
        fprintf('\t9. Half-Pel + Multiple Frames\n');
        fprintf('\t10. Multiple Frames + Chroma SubSampling\n');
        fprintf('\t11. Half-Pel + Multiple Frames + Chroma SubSampling\n');
        fprintf('\t12. Adaptive Decision function\n');
        OptimizationScheme = input('\nWhich type of Optimization Scheme you need to Implement?\n');
            if OptimizationScheme == 1
                Scheme = string('No Optimization');
            elseif OptimizationScheme == 2
                Scheme = string('Half-Pel Partial');
            elseif OptimizationScheme == 3
                Scheme = string('Half-Pel Complete');
            elseif OptimizationScheme == 4
                Scheme = string('Quarter-Pel Partial');
            elseif OptimizationScheme == 5
                Scheme = string('Quarter-Pel Complete');
            elseif OptimizationScheme == 6
                Scheme = string('MultiFrame');
            elseif OptimizationScheme == 7
                Scheme = string('Chroma');
            elseif OptimizationScheme == 8
                Scheme = string('Half-Pel+Chroma');
            elseif OptimizationScheme == 9
                Scheme = string('Half-Pel+Multi');
            elseif OptimizationScheme == 10
                Scheme = string('Chroma+Multi');
            elseif OptimizationScheme == 11
                Scheme = string('Half-Pel+MultiFrame+Chroma');
            else
                error('Wrong Input');
            end
    elseif SearchType == 2
        BlockSearch = string('LogSearch');
        fprintf('\t1. No Optimization\n');
        OptimizationScheme = input('\nWhich type of Optimization Scheme you need to Implement?\n');
        if OptimizationScheme == 1
            Scheme = string('No Optimization');
        else
                error('Wrong Input');
        end
    else
        error('Wrong Input');
    end

    
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
    fprintf('------ Motion Compensation Goingon ------\n');

    %% Motion Estimation and Motion Compensation
    for iframes = 1:21
        Fr_Num = iframes+19;
%         fprintf('------ Decoding Frame - %d ------\n',iframes);
        
        %% First Frame for DCT - Based Still Frame Coding
        if (iframes == 1)
            FirstFrame = double(imread('data/sequences/foreman20_40_RGB/foreman0020.bmp'));
            [FrameHeight FrameWidth FrameDim] = size(FirstFrame);
            [FirstFrame_YCbCr(:,:,1) FirstFrame_YCbCr(:,:,2) FirstFrame_YCbCr(:,:,3)] = ictRGB2YCbCr(FirstFrame(:,:,1),FirstFrame(:,:,2), FirstFrame(:,:,3));

            %% Zero Run Length Encoding
            FirstFrame_zeroRun = IntraEncode_YCbCr(FirstFrame_YCbCr,Scaling_Factor);
            
            %% Huffman Encoding & Decoding
            bytestream = enc_huffman_new(FirstFrame_zeroRun-Lower+1, BinCode, Codelengths);
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
%             fprintf('------ Frame - %d - Decoded ------\n',iframes);
        
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

            %% Motion Estimation & Encoding & Motion Compensation Decoding
            
            if (strcmp(BlockSearch,'FullBlockSearch') == 1)
                if (strcmp(Scheme,'No Optimization') == 1)
                    [Error_Frame(:,:,1) Error_Frame(:,:,2) Error_Frame(:,:,3) Motion_Vector] = MotionEstimation_FullSearch(Current_Frame_YCbCr,Ref_Frame,BlockSize,SearchRange);
                    zeroRun = IntraEncode_YCbCr(Error_Frame,Scaling_Factor);
                    Decoded_Ref_Frame = IntraDecode_YCbCr(zeroRun,Motion_Vector,Ref_Frame,Scaling_Factor);
                elseif (strcmp(Scheme,'Half-Pel Partial') == 1)
                    a = 0.5; b = 0.5;
                    [Error_Frame(:,:,1) Error_Frame(:,:,2) Error_Frame(:,:,3) Motion_Vector] = MotionEstimation_SubPelPartial(Current_Frame_YCbCr,Ref_Frame,BlockSize,SearchRange,a,b);
                    zeroRun = IntraEncode_YCbCr(Error_Frame,Scaling_Factor);
                    Decoded_Ref_Frame = IntraDecode_YCbCr_SubPel(zeroRun,Motion_Vector,Ref_Frame,Scaling_Factor,a,b);
                elseif (strcmp(Scheme,'Half-Pel Complete') == 1)
                    a = 0.5; b = 0.5;
                    [Error_Frame(:,:,1) Error_Frame(:,:,2) Error_Frame(:,:,3) Motion_Vector] = MotionEstimation_SubPel(Current_Frame_YCbCr,Ref_Frame,BlockSize,SearchRange,a,b);
                    zeroRun = IntraEncode_YCbCr(Error_Frame,Scaling_Factor);
                    Decoded_Ref_Frame = IntraDecode_YCbCr_SubPel(zeroRun,Motion_Vector,Ref_Frame,Scaling_Factor,a,b);
                elseif (strcmp(Scheme,'Quarter-Pel Partial') == 1)
                    a = 0.25; b = 0.25;
                    [Error_Frame(:,:,1) Error_Frame(:,:,2) Error_Frame(:,:,3) Motion_Vector] = MotionEstimation_SubPelPartial(Current_Frame_YCbCr,Ref_Frame,BlockSize,SearchRange,a,b);
                    zeroRun = IntraEncode_YCbCr(Error_Frame,Scaling_Factor);
                    Decoded_Ref_Frame = IntraDecode_YCbCr_SubPel(zeroRun,Motion_Vector,Ref_Frame,Scaling_Factor,a,b);
                elseif (strcmp(Scheme,'Quarter-Pel Complete') == 1)
                    a = 0.25; b = 0.25;
                    [Error_Frame(:,:,1) Error_Frame(:,:,2) Error_Frame(:,:,3) Motion_Vector] = MotionEstimation_SubPel(Current_Frame_YCbCr,Ref_Frame,BlockSize,SearchRange,a,b);
                    zeroRun = IntraEncode_YCbCr(Error_Frame,Scaling_Factor);
                    Decoded_Ref_Frame = IntraDecode_YCbCr_SubPel(zeroRun,Motion_Vector,Ref_Frame,Scaling_Factor,a,b);
                elseif (strcmp(Scheme,'MultiFrame') == 1)
                    if (iframes >= 3)
                        Ref_Frame_Y_2 = Decoded_Frames_Y(:,(iframes-3)*FrameWidth+1:(iframes-2)*FrameWidth);
                        Ref_Frame_Cb_2 = Decoded_Frames_Cb(:,(iframes-3)*FrameWidth+1:(iframes-2)*FrameWidth);
                        Ref_Frame_Cr_2 = Decoded_Frames_Cr(:,(iframes-3)*FrameWidth+1:(iframes-2)*FrameWidth);
                        Ref_Frame_2(:,:,1) = Ref_Frame_Y_2;
                        Ref_Frame_2(:,:,2) = Ref_Frame_Cb_2;
                        Ref_Frame_2(:,:,3) = Ref_Frame_Cr_2;
                        Ref_Frame_MR = [Ref_Frame Ref_Frame_2];
                    else
                        Ref_Frame_MR = Ref_Frame;
                    end
                    [Error_Frame(:,:,1) Error_Frame(:,:,2) Error_Frame(:,:,3) Motion_Vector MR] = MotionEstimation_MultiFrame(Current_Frame_YCbCr,Ref_Frame_MR,BlockSize,SearchRange,iframes);
                    zeroRun = IntraEncode_YCbCr(Error_Frame,Scaling_Factor);
                    Decoded_Ref_Frame = IntraDecode_YCbCr_Multi(zeroRun,Motion_Vector,Ref_Frame_MR,Scaling_Factor,MR);
                elseif (strcmp(Scheme,'Chroma') == 1)
                    [Error_Frame_Y Error_Frame_Cb Error_Frame_Cr Motion_Vector] = MotionEstimation_Chroma(Current_Frame_YCbCr,Ref_Frame,BlockSize,SearchRange);
                    zeroRun = IntraEncode_YCbCr_Chroma(Error_Frame_Y,Error_Frame_Cb,Error_Frame_Cr,Scaling_Factor);
                    Decoded_Ref_Frame = IntraDecode_YCbCr_Chroma(zeroRun,Motion_Vector,Ref_Frame,Scaling_Factor);
                elseif (strcmp(Scheme,'Half-Pel+Multi') == 1)
                    a = 0.5; b = 0.5;
                    if (iframes >= 3)
                        Ref_Frame_Y_2 = Decoded_Frames_Y(:,(iframes-3)*FrameWidth+1:(iframes-2)*FrameWidth);
                        Ref_Frame_Cb_2 = Decoded_Frames_Cb(:,(iframes-3)*FrameWidth+1:(iframes-2)*FrameWidth);
                        Ref_Frame_Cr_2 = Decoded_Frames_Cr(:,(iframes-3)*FrameWidth+1:(iframes-2)*FrameWidth);
                        Ref_Frame_2(:,:,1) = Ref_Frame_Y_2;
                        Ref_Frame_2(:,:,2) = Ref_Frame_Cb_2;
                        Ref_Frame_2(:,:,3) = Ref_Frame_Cr_2;
                        Ref_Frame_MR = [Ref_Frame Ref_Frame_2];
                    else
                        Ref_Frame_MR = Ref_Frame;
                    end
                    [Error_Frame(:,:,1) Error_Frame(:,:,2) Error_Frame(:,:,3) Motion_Vector MR] = MotionEstimation_SubPelMulti(Current_Frame_YCbCr,Ref_Frame_MR,BlockSize,SearchRange,iframes,a,b);
                    zeroRun = IntraEncode_YCbCr(Error_Frame,Scaling_Factor);
                    Decoded_Ref_Frame = IntraDecode_YCbCr_SubPelMulti(zeroRun,Motion_Vector,Ref_Frame_MR,Scaling_Factor,MR,a,b);
                elseif (strcmp(Scheme,'Chroma+Multi') == 1)
                    if (iframes >= 3)
                        Ref_Frame_Y_2 = Decoded_Frames_Y(:,(iframes-3)*FrameWidth+1:(iframes-2)*FrameWidth);
                        Ref_Frame_Cb_2 = Decoded_Frames_Cb(:,(iframes-3)*FrameWidth+1:(iframes-2)*FrameWidth);
                        Ref_Frame_Cr_2 = Decoded_Frames_Cr(:,(iframes-3)*FrameWidth+1:(iframes-2)*FrameWidth);
                        Ref_Frame_2(:,:,1) = Ref_Frame_Y_2;
                        Ref_Frame_2(:,:,2) = Ref_Frame_Cb_2;
                        Ref_Frame_2(:,:,3) = Ref_Frame_Cr_2;
                        Ref_Frame_MR = [Ref_Frame Ref_Frame_2];
                    else
                        Ref_Frame_MR = Ref_Frame;
                    end
                    [Error_Frame_Y Error_Frame_Cb Error_Frame_Cr Motion_Vector MR] = MotionEstimation_ChromaMulti(Current_Frame_YCbCr,Ref_Frame_MR,BlockSize,SearchRange,iframes);
                    zeroRun = IntraEncode_YCbCr_Chroma(Error_Frame_Y,Error_Frame_Cb,Error_Frame_Cr,Scaling_Factor);
                    Decoded_Ref_Frame = IntraDecode_YCbCr_ChromaMulti(zeroRun,Motion_Vector,Ref_Frame_MR,Scaling_Factor,MR);
                elseif (strcmp(Scheme,'Half-Pel+Chroma') == 1)
                    a = 0.5; b = 0.5;
                    [Error_Frame_Y Error_Frame_Cb Error_Frame_Cr Motion_Vector] = MotionEstimation_SubPelChroma(Current_Frame_YCbCr,Ref_Frame,BlockSize,SearchRange,a,b);
                    zeroRun = IntraEncode_YCbCr_Chroma(Error_Frame_Y,Error_Frame_Cb,Error_Frame_Cr,Scaling_Factor);
                    Decoded_Ref_Frame = IntraDecode_YCbCr_SubPelChroma(zeroRun,Motion_Vector,Ref_Frame,Scaling_Factor,a,b);
                elseif (strcmp(Scheme,'Half-Pel+MultiFrame+Chroma') == 1)
                    a = 0.5; b = 0.5;
                    if (iframes >= 3)
                        Ref_Frame_Y_2 = Decoded_Frames_Y(:,(iframes-3)*FrameWidth+1:(iframes-2)*FrameWidth);
                        Ref_Frame_Cb_2 = Decoded_Frames_Cb(:,(iframes-3)*FrameWidth+1:(iframes-2)*FrameWidth);
                        Ref_Frame_Cr_2 = Decoded_Frames_Cr(:,(iframes-3)*FrameWidth+1:(iframes-2)*FrameWidth);
                        Ref_Frame_2(:,:,1) = Ref_Frame_Y_2;
                        Ref_Frame_2(:,:,2) = Ref_Frame_Cb_2;
                        Ref_Frame_2(:,:,3) = Ref_Frame_Cr_2;
                        Ref_Frame_MR = [Ref_Frame Ref_Frame_2];
                    else
                        Ref_Frame_MR = Ref_Frame;
                    end
                    [Error_Frame_Y Error_Frame_Cb Error_Frame_Cr Motion_Vector MR] = MotionEstimation_SubPelMultiChroma(Current_Frame_YCbCr,Ref_Frame_MR,BlockSize,SearchRange,iframes,a,b);
                    zeroRun = IntraEncode_YCbCr_Chroma(Error_Frame_Y,Error_Frame_Cb,Error_Frame_Cr,Scaling_Factor);
                    Decoded_Ref_Frame = IntraDecode_YCbCr_SubPelMultiChroma(zeroRun,Motion_Vector,Ref_Frame_MR,Scaling_Factor,MR,a,b);
                elseif (strcmp(Scheme,'Adaptive') == 1)
                    if (iframes >=3)
                        [Error_Frame(:,:,1) Error_Frame(:,:,2) Error_Frame(:,:,3) Motion_Vector] = MotionEstimation_FullSearchAdaptive(Current_Frame_YCbCr,Ref_Frame,BlockSize,SearchRange,BinaryTree_MV, HuffCode_MV, BinCode_MV, Codelengths_MV);
                    else
                        [Error_Frame(:,:,1) Error_Frame(:,:,2) Error_Frame(:,:,3) Motion_Vector] = MotionEstimation_FullSearch(Current_Frame_YCbCr,Ref_Frame,BlockSize,SearchRange);
                    end
                    zeroRun = IntraEncode_YCbCr(Error_Frame,Scaling_Factor);
                    Decoded_Ref_Frame = IntraDecode_YCbCr(zeroRun,Motion_Vector,Ref_Frame,Scaling_Factor); 
                end
                
            elseif (strcmp(BlockSearch,'LogSearch') == 1)
                
                if (strcmp(Scheme,'No Optimization') == 1)
                    [Error_Frame(:,:,1) Error_Frame(:,:,2) Error_Frame(:,:,3) Motion_Vector] = MotionEstimation_LogSearch(Current_Frame_YCbCr,Ref_Frame,BlockSize,SearchRange);
                    zeroRun = IntraEncode_YCbCr(Error_Frame,Scaling_Factor);
                    Decoded_Ref_Frame = IntraDecode_YCbCr(zeroRun,Motion_Vector,Ref_Frame,Scaling_Factor);
                end
            end

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
%             Decoded_Ref_Frame = IntraDecode_YCbCr(zeroRun,Motion_Vector,Ref_Frame,Scaling_Factor);
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
%             Bitrate_Frame = length(bytestream_Frame)*8 / (FrameWidth * FrameHeight);
            Bitrate_MV = length(bytestream_MV)*8 / (FrameWidth * FrameHeight);
            Bitrate_Frames(:,iframes) = Bitrate_Frame;
            Bitrate_MVs(:,iframes) = Bitrate_MV;
            Bitrate_Total(:,iframes) = Bitrate_Frame + Bitrate_MV;
            
%         fprintf('------ Frame - %d - Decoded ------\n',iframes);
        end 
    end
    fprintf('------ Motion Compensation Done ------\n');
    %% Required Outputs
    Final_rate = mean(Bitrate_Total)
    Final_PSNR = mean(PSNR_Frames)

    Bitrate_all(run) = mean(Final_rate);
    PSNR_all(run) = Final_PSNR;
    run = run+1;
end
%% R-D Plot
Bitrate_PSNR = vertcat(Bitrate_all,PSNR_all)
plot(Bitrate_all,PSNR_all,'-*','LineWidth',2,'MarkerSize',5);
xlabel('Rate [bit/pixel]');
ylabel('PSNR [dB]');
grid on;
hold on;
% legend('Half-Pel Partial','Without Optimization','location','southeast')