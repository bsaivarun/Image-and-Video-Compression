function [Output Refinement RefinFlagTotal MaxBits Bitstream Bitstream_Sig] = EZWEncode(Wavelet,n)

[ImageHeight ImageWidth ImageDim] = size(Wavelet);

%% Splitting into Sign and Bit-Planes
SignPlane =  sign(Wavelet);
MaxBits = numel(decimalToBinaryVector(max(abs(Wavelet(:)))));
BitPlane = mat2cell(zeros(ImageHeight,ImageWidth*MaxBits),ImageHeight,ImageWidth*ones(1,MaxBits));

for col = 1:size(Wavelet,2)
    Binary = decimalToBinaryVector(abs(Wavelet(:,col)), MaxBits);
    
    for planes = 1:MaxBits
        
        BitPlane{planes}(:,col)= Binary(:,planes);
        
    end
end

%% EZWEncoding

PosNeg = 0;

EOB_Output = 555;
EOB_Refine = 777;
for planes = 1 : MaxBits
    i = 1;
%     Output{planes} = [];
    Refinement{planes} = [];
%     Bitstream{planes} = [];
%     Bitstream_Sig{planes} = [];
    loop = 0;
    OutIndex = 0;
    Table = zeros(ImageHeight,ImageWidth);
    if (planes > 1)
%         Bitstream{planes} = [Bitstream{planes} EOB_Output];
        RefinFlagTotal{planes} = RefinFlag;
        for ref = 1:size(RefinFlag,1)
            if (BitPlane{planes}(RefinFlag(ref,1),RefinFlag(ref,2)) == 1)
                Refinement{planes} = [Refinement{planes} 1];
                Bitstream_Sig{planes}(1,ref) = 2;
%                 Bitstream_Sig{planes} = [Bitstream_Sig{planes} 2];
                Table(RefinFlag(ref,1),RefinFlag(ref,2),1) = 1;
            elseif (BitPlane{planes}(RefinFlag(ref,1),RefinFlag(ref,2)) == 0)
                Refinement{planes} = [Refinement{planes} 0];
                Bitstream_Sig{planes}(1,ref) = 3;
%                 Bitstream_Sig{planes} = [Bitstream_Sig{planes} 3];
                Table(RefinFlag(ref,1),RefinFlag(ref,2),1) = 1;
            end
        end
%         Bitstream{planes} = [Bitstream{planes} EOB_Refine];
    end
    ColStart = 1;
    while (i<=n)
        [WLHeight WLWidth] = size(Wavelet);
        MinHeight = ceil(WLHeight/2^(n-i+1));
        MinWidth = ceil(WLWidth/2^(n-i+1));
        MaxHeight = ceil(WLHeight/2^(n-i));
        MaxWidth = ceil(WLWidth/2^(n-i));
            
        RowStart = 1;
        Height = MinHeight;
        Width = ColStart+MinWidth-1;
        while (RowStart <= Height)         
            while (ColStart <= Width)
                loop = loop+1;
                if Table(RowStart,ColStart) ~= 1
                    OutIndex = OutIndex+1;
                    if (BitPlane{planes}(RowStart,ColStart) == 1)
                        PosNeg = PosNeg+1;
                        if (SignPlane(RowStart,ColStart) == 1)
                            Table(RowStart,ColStart,1) = 1;
                            Output{planes}(1,OutIndex) = string('POS');
                            Bitstream{planes}(1,2*OutIndex-1:2*OutIndex) = [0 0];
%                             Output{planes} = [Output{planes} string('POS')];
%                             Bitstream{planes} = [Bitstream{planes} 0 0];
                            RefinFlag(PosNeg,:) = [RowStart,ColStart];
                        elseif (SignPlane(RowStart,ColStart) == -1)
                            Table(RowStart,ColStart,1) = 1;
                            Output{planes}(1,OutIndex) = string('NEG');
                            Bitstream{planes}(1,2*OutIndex-1:2*OutIndex) = [1 1];
%                             Output{planes} = [Output{planes} string('NEG')];
%                             Bitstream{planes} = [Bitstream{planes} 1 1];
                            RefinFlag(PosNeg,:) = [RowStart,ColStart];
                        end

                    elseif (BitPlane{planes}(RowStart,ColStart) == 0)
                        Tree = 0;
                        ChildrenLocation = [];
                        prev_i = i;
                        pointer = 1;
                        if (i == n)
                            Table(RowStart,ColStart,1) = 1;
                            Output{planes}(1,OutIndex) = string('IZ');
                            Bitstream{planes}(1,2*OutIndex-1:2*OutIndex) = [0 1];
%                             Output{planes} = [Output{planes} string('IZ')];
%                             Bitstream{planes} = [Bitstream{planes} 0 1];
                        elseif (RowStart <= MinHeight) && (ColStart <= MinWidth)
                            ChildrenLocation = [RowStart ColStart;RowStart ColStart+MinWidth;RowStart+MinHeight ColStart;RowStart+MinHeight ColStart+MinWidth];
                            Children = [BitPlane{planes}(RowStart,ColStart) BitPlane{planes}(RowStart,ColStart+MinWidth);...
                                        BitPlane{planes}(RowStart+MinHeight,ColStart) BitPlane{planes}(RowStart+MinHeight,ColStart+MinWidth)];
                            Tree = sum(sum(Children(:)));
                            while (Tree == 0) && (pointer<=15)
                                pointer = pointer+1;
                                child_row = ChildrenLocation(pointer,1);
                                child_col = ChildrenLocation(pointer,2);
                                child_value = BitPlane{planes}(child_row,child_col);
                                child_row = (2)*(child_row-1)+1;
                                child_col = (2)*(child_col-1)+1;
                                ChildrenLocation = [ChildrenLocation;[child_row child_col];[child_row child_col+1];[child_row+1 child_col];[child_row+1 child_col+1]];
                            end
                            for loc = 1:size(ChildrenLocation,1)
                                ChildrenLocation(loc,3) = BitPlane{planes}(ChildrenLocation(loc,1),ChildrenLocation(loc,2));
                            end
                            Tree = sum(sum(ChildrenLocation(:,3)));
                            if Tree == 0
                                Table(RowStart,ColStart,1) = 1;
                                for loc = 1:size(ChildrenLocation,1)
                                    Table(ChildrenLocation(loc,1),ChildrenLocation(loc,2),1) = 1;
                                end
                                Output{planes}(1,OutIndex) = string('ZTR');
                                Bitstream{planes}(1,2*OutIndex-1:2*OutIndex) = [1 0];
%                                 Output{planes} = [Output{planes} string('ZTR')];
%                                 Bitstream{planes} = [Bitstream{planes} 1 0];
                            else
                                Table(RowStart,ColStart,1) = 1;
                                Output{planes}(1,OutIndex) = string('IZ');
                                Bitstream{planes}(1,2*OutIndex-1:2*OutIndex) = [0 1];
%                                 Output{planes} = [Output{planes} string('IZ')];
%                                 Bitstream{planes} = [Bitstream{planes} 0 1];
                            end
                        else                        
                            child_row = (2)*(RowStart-1)+1;
                            child_col = (2)*(ColStart-1)+1;
                            ChildrenLocation = [child_row child_col;child_row child_col+1;child_row+1 child_col;child_row+1 child_col+1];
                            Children = [BitPlane{planes}(child_row,child_col) BitPlane{planes}(child_row,child_col+1);...
                                        BitPlane{planes}(child_row+1,child_col) BitPlane{planes}(child_row+1,child_col+1)];
                            Tree = sum(sum(Children(:)));
                            pointer = 0;
                            while (Tree == 0) && (pointer<=3) && (i<2)
                                pointer = pointer+1;
                                child_row = ChildrenLocation(pointer,1);
                                child_col = ChildrenLocation(pointer,2);
                                child_value = BitPlane{planes}(child_row,child_col);
                                child_row = (2)*(child_row-1)+1;
                                child_col = (2)*(child_col-1)+1;
                                ChildrenLocation = [ChildrenLocation;[child_row child_col];[child_row child_col+1];[child_row+1 child_col];[child_row+1 child_col+1]];
                            end
                            for loc = 1:size(ChildrenLocation,1)
                                ChildrenLocation(loc,3) = BitPlane{planes}(ChildrenLocation(loc,1),ChildrenLocation(loc,2));
                            end
                            Tree = sum(sum(ChildrenLocation(:,3)));
                            if Tree == 0
                                Table(RowStart,ColStart,1) = 1;
                                for loc = 1:size(ChildrenLocation,1)
                                    Table(ChildrenLocation(loc,1),ChildrenLocation(loc,2),1) = 1;
                                end
                                Output{planes}(1,OutIndex) = string('ZTR');
                                Bitstream{planes}(1,2*OutIndex-1:2*OutIndex) = [1 0];
%                                 Output{planes} = [Output{planes} string('ZTR')];
%                                 Bitstream{planes} = [Bitstream{planes} 1 0];
                            else
                                Table(RowStart,ColStart,1) = 1;
                                Output{planes}(1,OutIndex) = string('IZ');
                                Bitstream{planes}(1,2*OutIndex-1:2*OutIndex) = [0 1];
%                                 Output{planes} = [Output{planes} string('IZ')];
%                                 Bitstream{planes} = [Bitstream{planes} 0 1];
                            end
                        end
                    end
                end
                ColStart = ColStart+1;
            end
            RowStart = RowStart+1;
            if (RowStart == MinHeight+1) && (ColStart == MinWidth+1)
                RowStart = 1;
                ColStart = MinWidth+1;
                Height = MinHeight;
                Width = MaxWidth;
            elseif (RowStart == MinHeight+1) && (ColStart == MaxWidth+1)
                RowStart = MinHeight+1;
                ColStart = 1;
                Height = MaxHeight;
                Width = MinWidth;
            elseif (RowStart == MaxHeight+1) && (ColStart == MinWidth+1)
                RowStart = MinHeight+1;
                ColStart = MinWidth+1;
                Height = MaxHeight;
                Width = MaxWidth;
            elseif (RowStart == MaxHeight+1) && (ColStart == MaxWidth+1)
                i = i+1;
                ColStart = MaxWidth+1;
            elseif (ColStart > Width) && (RowStart <= Height)
                ColStart = ColStart-MinWidth;
            end
        end 
    end
end

% TotalEncoded = numel(Output{1})+numel(Output{2})+numel(Output{3})+numel(Output{4})+ ...
%                numel(Output{5})+numel(Output{6})+numel(Output{7})+numel(Output{8})+ ...
%                numel(Refinement{1})+numel(Refinement{2})+numel(Refinement{3})+ ...
%                numel(Refinement{4})+numel(Refinement{5})+numel(Refinement{6})+ ...
%                numel(Refinement{7})+numel(Refinement{8});
% TotalOutput = numel(Output{1})+numel(Output{2})+numel(Output{3})+numel(Output{4})+ ...
%               numel(Output{5})+numel(Output{6})+numel(Output{7})+numel(Output{8});
% TotalRefinement = numel(Refinement{1})+numel(Refinement{2})+numel(Refinement{3})+ ...
%                   numel(Refinement{4})+numel(Refinement{5})+numel(Refinement{6})+ ...
%                   numel(Refinement{7})+numel(Refinement{8});
% TotalBits = (TotalOutput*2)+TotalRefinement;
% BitRate = TotalBits/(ImageHeight*ImageWidth);
% fprintf('\n\tBitRate = %f bpp\n',BitRate);
% save EZWEncode_new.mat
    
        
end