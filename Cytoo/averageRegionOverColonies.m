function [avg, err]=averageRegionOverColonies(matfile,colshape,coord,radius,columns,ncolumns,coord_type,coord_unit)
% [avg, err]=averageRegionOverColonies(matfile,colshape,coord,radius,columns,ncolumns,coord_type,coord_unit)
% ---------------------------------------------------
% Average value in a region defined by coord and radius over the colonies
% in the plate object in the matfile. Colshape is either the number of the
% shape on the cytoo custom dish, or -1 = 1000um, -2 = 500 um, -3 = 250 um,
% and -4 = smaller on the arena dish. 
% columns -- data columns to average,
% ncolumns -- normalization columns to use (1 for each data column)
%
% See also getColonyPoints, colony/getPointsAroundCoordinate
pp=load(matfile,'plate1');

if ~exist('coord_type','var')
    coord_type='cartesian';
end

if ~exist('coord_unit','var')
    coord_unit='pixel';
end

if colshape > 0
    colinds=find([pp.plate1.colonies.shape]==colshape);
else
    colsize = -colshape;
    switch colsize
        case 1
            colinds=pp.plate1.inds1000;
        case 2
            colinds=pp.plate1.inds500;
        case 3
            colinds=pp.plate1.inds250;
        case 4
            colinds=pp.plate1.indsSm;
        otherwise
            colinds=pp.plate1.inds1000;
            disp('WARNING: invalid colsize, must be 1-4, defaulting to 1');
    end
end

ncol=length(colinds);
allval=zeros(ncol,length(columns));


for jj=1:size(coord,1)
for ii=1:ncol
    col=pp.plate1.colonies(colinds(ii));
    inds=getColonyPoints(col,coord(jj,:),radius,coord_type,coord_unit);
    allval(ii,:)=meannonan(col.data(inds,columns)./col.data(inds,ncolumns));
end 
avg(jj,:)=mean(allval);
err(jj,:)=std(allval);
end