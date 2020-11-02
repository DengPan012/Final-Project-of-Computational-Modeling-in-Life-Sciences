function [CrossX,CrossY]= conjunction(X1,Y1,X2,Y2)
% this fuction is used to find the conjuction of two sequence
% x1 and y1 should be the same length, so do x2 and y2
%
PointsX=[];
PointsY=[];
dis=@(x1,y1,x2,y2)sqrt((x1-x2)^2+(y1-y2)^2);
threshold=0.01;
for p=1:length(X1)
    x1=X1(p);y1=Y1(p);
    for q=1:length(X2)
        x2=X2(q);y2=Y2(q);
        if dis(x1,y1,x2,y2) < threshold
            PointsX=[PointsX,x1];
            PointsY=[PointsY,y1];
        end
    end
end
t_min=0.05;
Adj_Box=zeros(size(PointsX));
num=1;
for m=2:length(PointsX)
    adjacent=dis(PointsX(m),PointsY(m),PointsX(m-1),PointsY(m-1))<t_min;
    if ~adjacent
        num=num+1;
    end 
    Adj_Box(m)=num;
end
CrossX=[];CrossY=[];
for n=1:num
    samex=PointsX(Adj_Box==n);
    samey=PointsY(Adj_Box==n);
    len=length(samex);
    if mod(len,2)
        CrossX=[CrossX,samex((len+1)/2)];
        CrossY=[CrossY,samey((len+1)/2)];
    else
        CrossX=[CrossX,samex(len/2)];
        CrossY=[CrossY,samey(len/2)];
    end
end
end

