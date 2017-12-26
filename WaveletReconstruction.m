function Wavelet_Reconstructed = WaveletReconstruction(Wavelet_Decoded,n,G0,G1)

Wavelet_Reconstructed = Wavelet_Decoded;
for i = 1 : n
   
    [WLHeight WLWidth] = size(Wavelet_Reconstructed);
    MinHeight = ceil(WLHeight/2^(n-i+1));
    MinWidth = ceil(WLWidth/2^(n-i+1));
    MaxHeight = ceil(WLHeight/2^(n-i));
    MaxWidth = ceil(WLWidth/2^(n-i));
    
    LL = Wavelet_Reconstructed(1:MinHeight,1:MinWidth);
    HL = Wavelet_Reconstructed(1:MinHeight,MinWidth+1:MaxWidth);
    LH = Wavelet_Reconstructed(MinHeight+1:MaxHeight,1:MinWidth);
    HH = Wavelet_Reconstructed(MinHeight+1:MaxHeight,MinWidth+1:MaxWidth);
    
    LowLow = zeros(MinHeight,MaxWidth);
    LowLow(:,1:2:end) = LL;
    RowConvLL = RowSymConv(LowLow,G0);
    
    HighLow = zeros(MinHeight,MaxWidth);
    HighLow(:,2:2:end) = HL;
    RowConvHL = RowSymConv(HighLow,G1);
    
    Low = zeros(MaxHeight,MaxWidth);
    Low(1:2:end,:) = RowConvLL + RowConvHL;
    ColConvLow = ColSymConv(Low,G0);
    
    LowHigh = zeros(MinHeight,MaxWidth);
    LowHigh(:,1:2:end) = LH;
    RowConvLH = RowSymConv(LowHigh,G0);
    
    HighHigh = zeros(MinHeight,MaxWidth);
    HighHigh(:,2:2:end) = HH;
    RowConvHH = RowSymConv(HighHigh,G1);
    
    High = zeros(MaxHeight,MaxWidth);
    High(2:2:end,:) = RowConvLH + RowConvHH;
    ColConvHigh = ColSymConv(High,G1);
    
    Wavelet_Reconstructed(1:MaxHeight,1:MaxWidth) = ColConvLow + ColConvHigh;    
%     figure;
%     imshow(Wavelet_Reconstructed/256);
end

end