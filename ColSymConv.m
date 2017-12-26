function Col = ColSymConv(Image,Filter)

    FilterLength = length(Filter);
    [Height Width] = size(Image);
    Col = [Image(1+(FilterLength-1)/2:-1:2,:);Image;Image(Height-1:-1:Height-(FilterLength-1)/2,:)];
    Col = conv2(Col,Filter');
    Col = Col(FilterLength:Height+FilterLength-1,:);

end