function createSphereDcmExport(Z,diameter,depth,pixelSpacing,waterSlabDepth,Pmod,index)
if nargin < 7
    modulated = false;
else
    modulated = true;
end

sphereVolume = round(4/3*pi*(diameter/2*pixelSpacing)^3/1000); % sphere volume in cm^3
depth = round(depth./pixelSpacing+waterSlabDepth);  % depths in voxel

for i=1:size(Z,1)
    for j=1:size(Z,2)
        for k=1:size(Z,3)
            if sqrt((size(Z,1)/2-i)^2+(size(Z,2)/2-j)^2+(size(Z,3)/2-k)^2) <= diameter/2-0.1*diameter/2
                Z(i,j-size(Z,2)/2+depth,k)=1009;
            end
        end
    end
end


% read a default DICOM-header
info = dicominfo('default.dcm');
% set up different initialization
rand('state', sum(100*clock));
info.SeriesInstanceUID = ['2.16.840.1.113662.2.1.2766.24698.2050131.2090506.' int2str(10000000 + round(1000000 * rand)) '.' int2str(10 + round(10 * rand))];
info.StudyInstanceUID = ['2.16.840.1.113662.2.1.1766.14698.1050131.' int2str(1000000 + round(100000 * rand))];

if modulated
    path_id = ['DICOMS_MODULATED_',num2str(Pmod),'\DICOMS_MODULATED_size_',num2str(sphereVolume),'cm^3_depth_',num2str(depth),'mm/dicom_',int2str(index)];
else
    path_id = ['DICOMS_NON_MODULATED\DICOMS_NON_MODULATED_size_',num2str(sphereVolume),'cm^3_depth_',num2str(depth),'mm/'];
end
mkdir(path_id);

Z_uint=uint16(Z);

for i=1:1:size(Z,3)
    info.ImagePositionPatient(1) = 0;
    info.ImagePositionPatient(2) = 0;
    info.ImagePositionPatient(3) = i * pixelSpacing; %Position of z-slice in mm
    info.OtherPatientID = 'PHANTOM';
    
    if modulated
        info.PatientID = 'Mod';
        filenam = [path_id '\DICOMS_Manipulated_size_',num2str(sphereVolume),'cm^3_depth_',num2str(depth),'mm' int2str(i) '.dcm'];
    else
        info.PatientID = 'Non_mod';
        filenam = [path_id '\DICOMS_Non_Manipulated_size_',num2str(sphereVolume),'cm^3_depth_',num2str(depth),'mm' int2str(i) '.dcm']; %Set name of DICOM-Files
    end
        
    info.PixelSpacing(1) = pixelSpacing; %Spacing in x-direction in mm
    info.PixelSpacing(2) = pixelSpacing; %Spacing in y-direction in mm
    info.SliceThickness = pixelSpacing; %thickness of slice in z-direction
    info.PatientName.FamilyName = 'IMPS';
    info.PatientName.GivenName = 'PHANTOM';
    info.RescaleIntercept = -1000;
    info.RescaleSlope = 1;
    dicomwrite(Z_uint(:,:,i),filenam,info);
end

end

