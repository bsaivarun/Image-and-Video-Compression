function Row = RowSymConv(Image,Filter)

    FilterLength = length(Filter);
    [Height Width] = size(Image);
    Row = [Image(:,1+(FilterLength-1)/2:-1:2) Image Image(:,Width-1:-1:Width-(FilterLength-1)/2)];
    Row = conv2(Row,Filter);
    Row = Row(:,FilterLength:Width+FilterLength-1);

end