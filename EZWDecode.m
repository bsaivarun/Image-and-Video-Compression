function Wavelet_Decoded = EZWDecode(Output,Refinement,RefinFlagTotal,OriginalImage,n,MaxBits)

% OriginalImage = (imread('data/Images/lena_gray.tif'));
% OriginalImage = double((OriginalImage));
[ImageHeight ImageWidth ImageDim] = size(OriginalImage);
% n = input('How many levels of Decomposition required?\n');
% n = 3;

%% EZWDecoding

BitPlane_Decoded = mat2cell(zeros(ImageHeight,ImageWidth*MaxBits),ImageHeight,ImageWidth*ones(1,MaxBits));
SignPlane_Decoded = zeros(ImageHeight,ImageWidth);
for planes = 1:numel(Output)

    Level = 1;
    loop = 0;
    Table = zeros(ImageHeight,ImageWidth);
    RowStart = 1;
    ColStart = 1;
    Location = 1;
    if (planes > 1)
        RefinFlag = RefinFlagTotal{planes};
        for ref = 1:size(Refinement{planes},2)
            if (Refinement{planes}(ref) == 1)
                BitPlane_Decoded{planes}(RefinFlag(ref,1),RefinFlag(ref,2)) = 1;
                Table(RefinFlag(ref,1),RefinFlag(ref,2),1) = 1;
            elseif (Refinement{planes}(ref) == 0)
                BitPlane_Decoded{planes}(RefinFlag(ref,1),RefinFlag(ref,2)) = 0;
                Table(RefinFlag(ref,1),RefinFlag(ref,2),1) = 1;
            end
        end
    end
    while (Location <= numel(Output{planes})) && (Level<=n)
        [WLHeight WLWidth] = size(BitPlane_Decoded{planes});
        MinHeight = ceil(WLHeight/2^(n-Level+1));
        MinWidth = ceil(WLWidth/2^(n-Level+1));
        MaxHeight = ceil(WLHeight/2^(n-Level));
        MaxWidth = ceil(WLWidth/2^(n-Level));
        RowStart = 1;
        Height = MinHeight;
        Width = ColStart+MinWidth-1;
        while (RowStart <= Height)         
            while (ColStart <= Width)
                loop = loop+1;
                if Table(RowStart,ColStart) ~= 1
                    if (strcmp(Output{planes}(Location),'POS') == 1)
                        BitPlane_Decoded{planes}(RowStart,ColStart) = 1;
                        SignPlane_Decoded(RowStart,ColStart) = 1;
                        Table(RowStart,ColStart) = 1;
                    elseif (strcmp(Output{planes}(Location),'NEG') == 1)
                        BitPlane_Decoded{planes}(RowStart,ColStart) = 1;
                        SignPlane_Decoded(RowStart,ColStart) = -1;
                        Table(RowStart,ColStart) = 1;
                    elseif (strcmp(Output{planes}(Location),'IZ') == 1)
                        BitPlane_Decoded{planes}(RowStart,ColStart) = 0;
                        SignPlane_Decoded(RowStart,ColStart) = 0;
                        Table(RowStart,ColStart) = 1;
                    elseif (strcmp(Output{planes}(Location),'ZTR') == 1)
                        BitPlane_Decoded{planes}(RowStart,ColStart) = 0;
                        SignPlane_Decoded(RowStart,ColStart) = 0;
                        Table(RowStart,ColStart) = 1;
                        ChildrenLocation = [];
                        if (RowStart <= MinHeight) && (ColStart <= MinWidth)
                            pointer = 1;
                            ChildrenLocation = [RowStart ColStart;RowStart ColStart+MinWidth;RowStart+MinHeight ColStart;RowStart+MinHeight ColStart+MinWidth];
                            while (pointer<=15)
                                pointer = pointer+1;
                                child_row = ChildrenLocation(pointer,1);
                                child_col = ChildrenLocation(pointer,2);
                                child_row = (2)*(child_row-1)+1;
                                child_col = (2)*(child_col-1)+1;
                                ChildrenLocation = [ChildrenLocation;[child_row child_col];[child_row child_col+1];[child_row+1 child_col];[child_row+1 child_col+1]];
                            end
                            for loc = 1:size(ChildrenLocation,1)
                                Table(ChildrenLocation(loc,1),ChildrenLocation(loc,2)) = 1;
%                                 Bitplane_Decoded{planes}(ChildrenLocation(loc,1),ChildrenLocation(loc,2)) = 3;
                            end
                        else
                            pointer = 0;
                            child_row = (2)*(RowStart-1)+1;
                            child_col = (2)*(ColStart-1)+1;
                            ChildrenLocation = [child_row child_col;child_row child_col+1;child_row+1 child_col;child_row+1 child_col+1];
                            while (pointer<=3) && (Level<2)
                                pointer = pointer+1;
                                child_row = ChildrenLocation(pointer,1);
                                child_col = ChildrenLocation(pointer,2);
                                child_row = (2)*(child_row-1)+1;
                                child_col = (2)*(child_col-1)+1;
                                ChildrenLocation = [ChildrenLocation;[child_row child_col];[child_row child_col+1];[child_row+1 child_col];[child_row+1 child_col+1]];
                            end
                            for loc = 1:size(ChildrenLocation,1)
                                Table(ChildrenLocation(loc,1),ChildrenLocation(loc,2)) = 1;
%                                 Bitplane_Decoded{planes}(ChildrenLocation(loc,1),ChildrenLocation(loc,2)) = 3;
                            end
        
                        end
                    end
                    Location = Location+1;
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
                Level = Level+1;
                ColStart = MaxWidth+1;
            elseif (ColStart > Width) && (RowStart <= Height)
                ColStart = ColStart-MinWidth;
            end
        end
    end
end

%% Reconstructing Wavelet from Sign and BipPlanes

for i = 1:size(BitPlane_Decoded,2)
    BitPlaneCombined(:,:,i) = BitPlane_Decoded{i};
end
BinaryBits = [];
for col = 1:WLWidth
    for channel = 1:MaxBits
        BinaryBits(:,channel) = BitPlaneCombined(:,col,channel);
    end
    Decimal(:,col) = binaryVectorToDecimal(BinaryBits(1:end,:));
end
Wavelet_Decoded = Decimal.*SignPlane_Decoded;

end