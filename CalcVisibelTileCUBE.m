clear;
% Viewport
Fh = pi/2;
Fv = pi/2;
vp_W = 960;
vp_H = 960;
face_W = 960;
face_H = 960;
phi =0; % Longitude  of viewport
theta = 0; %altitude of viewport
No_face = 6;
tile_hori_num = 2;
tile_ver_num = 1;
No_tile = tile_hori_num * tile_ver_num;
%
fileID = fopen('visible_mask_FoV_90_6f_2x1.txt','w');
for j=1:tile_ver_num
    for i=1:tile_hori_num
        tile_id = (j-1) * tile_hori_num + i;
        LB_tile_W(tile_id) = face_W/tile_hori_num * (i-1);
        HB_tile_W(tile_id) = face_W/tile_hori_num * i;
        LB_tile_H(tile_id) = face_H/tile_ver_num * (j-1);
        HB_tile_H(tile_id) = face_H/tile_ver_num * j;
        
    end
end
%
for phi=180:359
    for theta=-90:90
        N_ft = ExtractCubeTileCodOfVP(Fh, Fv, vp_W,vp_H, face_W, face_H, phi,theta,tile_hori_num,tile_ver_num,LB_tile_W,LB_tile_H,HB_tile_W,HB_tile_H);
        fprintf(fileID, '%d\t%d\t', phi, theta);
        for i=1:No_face
            for j=1:No_tile
                fprintf(fileID, '%d\t', N_ft(i,j));
            end
        end
        fprintf(fileID, '\n');
    end
end