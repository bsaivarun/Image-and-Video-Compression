function Wavelet = WaveletDecomposition(Image,F0,F1,n)

    for i = 1 : n

        ColConvHigh = ColSymConv(Image,F1);
        High = ColConvHigh(2:2:end,:);

        HH = RowSymConv(High,F1);
        HH = HH(:,2:2:end);

        LH = RowSymConv(High,F0);
        LH = LH(:,1:2:end);

        ColConvLow = ColSymConv(Image,F0);
        Low = ColConvLow(1:2:end,:);

        HL = RowSymConv(Low,F1);
        HL = HL(:,2:2:end);

        LL = RowSymConv(Low,F0);
        LL = LL(:,1:2:end);

        Wavelet(1:size(Image,1), 1:size(Image,2)) = [LL HL;LH HH];
        Image = LL;
    %     figure;
    %     imshow(Wavelet/256);
    end 
end